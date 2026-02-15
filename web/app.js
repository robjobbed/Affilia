const affiliateTab = document.getElementById("affiliateTab");
const companyTab = document.getElementById("companyTab");
const affiliatePanel = document.getElementById("affiliatePanel");
const companyPanel = document.getElementById("companyPanel");
const campaignList = document.getElementById("campaignList");
const contractForm = document.getElementById("contractForm");
const cardTemplate = document.getElementById("cardTemplate");

const authGate = document.getElementById("authGate");
const appShell = document.getElementById("appShell");
const authMessage = document.getElementById("authMessage");
const appMessage = document.getElementById("appMessage");
const authButtons = document.querySelectorAll(".auth-btn");
const sessionChip = document.getElementById("sessionChip");
const sessionName = document.getElementById("sessionName");
const sessionProvider = document.getElementById("sessionProvider");
const sessionAvatar = document.getElementById("sessionAvatar");
const logoutBtn = document.getElementById("logoutBtn");

const providerLabels = {
  x: "X",
  instagram: "Instagram",
  facebook: "Facebook",
  tiktok: "TikTok"
};

const STORAGE_KEYS = {
  demoSession: "affilia_demo_session",
  postedContracts: "affilia_posted_contracts",
  appliedContracts: "affilia_applied_contract_ids",
  activePanel: "affilia_active_panel"
};

const seededContracts = [
  {
    id: "seed-neoncart",
    isSeed: true,
    companyName: "NeonCart",
    companyHandle: "@neoncart",
    title: "US DTC Skincare Creator Contract",
    description: "Looking for creators and email publishers to drive first-purchase CPA growth.",
    category: "INFLUENCERS",
    commissionType: "CPA",
    commissionValue: 58,
    cookieWindowDays: 45,
    monthlyPayoutCap: 6500
  },
  {
    id: "seed-flowledger",
    isSeed: true,
    companyName: "FlowLedger",
    companyHandle: "@flowledger",
    title: "B2B SaaS Rev Share Program",
    description: "Need newsletter and content affiliates in fintech and founder ecosystems.",
    category: "EMAIL",
    commissionType: "REV SHARE",
    commissionValue: 30,
    cookieWindowDays: 60,
    monthlyPayoutCap: 12000
  }
];

let providerStatusById = new Map();
let apiAuthAvailable = true;
let contracts = [];
let appliedContractIds = new Set();

function readStorageJson(key, fallbackValue) {
  try {
    const raw = window.localStorage.getItem(key);
    if (!raw) return fallbackValue;
    return JSON.parse(raw);
  } catch {
    return fallbackValue;
  }
}

function writeStorageJson(key, value) {
  try {
    window.localStorage.setItem(key, JSON.stringify(value));
  } catch {
    // Ignore storage write errors.
  }
}

function removeStorageKey(key) {
  try {
    window.localStorage.removeItem(key);
  } catch {
    // Ignore storage delete errors.
  }
}

function loadContractsFromStorage() {
  const postedContracts = readStorageJson(STORAGE_KEYS.postedContracts, []);
  if (!Array.isArray(postedContracts)) return [...seededContracts];

  return [
    ...postedContracts.map((contract, index) => ({
      ...contract,
      id: contract.id || `saved-${index}-${Date.now()}`,
      isSeed: false
    })),
    ...seededContracts
  ];
}

function persistPostedContracts() {
  const postedContracts = contracts.filter((contract) => !contract.isSeed);
  writeStorageJson(STORAGE_KEYS.postedContracts, postedContracts);
}

function loadAppliedContractIds() {
  const ids = readStorageJson(STORAGE_KEYS.appliedContracts, []);
  if (!Array.isArray(ids)) return new Set();
  return new Set(ids.filter((id) => typeof id === "string"));
}

function persistAppliedContractIds() {
  writeStorageJson(STORAGE_KEYS.appliedContracts, Array.from(appliedContractIds));
}

function setAuthMessage(message, isError = false) {
  authMessage.textContent = message || "";
  authMessage.classList.toggle("error", Boolean(isError));
}

function setAppMessage(message, isError = false) {
  if (!appMessage) return;

  appMessage.textContent = message || "";
  appMessage.classList.toggle("error", Boolean(isError));
  appMessage.classList.toggle("hidden", !message);
}

function cleanAuthQueryParams() {
  const url = new URL(window.location.href);
  if (url.searchParams.has("auth") || url.searchParams.has("auth_error")) {
    url.searchParams.delete("auth");
    url.searchParams.delete("auth_error");
    window.history.replaceState({}, "", url.toString());
  }
}

function getQueryStatus() {
  const params = new URLSearchParams(window.location.search);
  return {
    auth: params.get("auth"),
    authError: params.get("auth_error")
  };
}

async function requestJson(url, options = {}) {
  const response = await fetch(url, {
    credentials: "include",
    ...options
  });

  const data = await response.json().catch(() => ({}));

  if (!response.ok) {
    throw new Error(data.error || data.message || "Request failed");
  }

  return data;
}

function setAuthButtonState(button, enabled, reason) {
  button.dataset.enabled = String(enabled);
  button.classList.toggle("disabled", !enabled);
  button.setAttribute("aria-disabled", String(!enabled));

  if (enabled) {
    button.title = "";
    return;
  }

  button.title = reason || "Provider is unavailable";
}

async function loadProviderStatus() {
  try {
    const data = await requestJson("/api/auth/providers");
    const providers = Array.isArray(data.providers) ? data.providers : [];

    providerStatusById = new Map(providers.map((provider) => [provider.id, provider]));

    authButtons.forEach((button) => {
      const provider = providerStatusById.get(button.dataset.provider);
      const enabled = Boolean(provider?.enabled);
      const reason = enabled
        ? ""
        : `${provider?.reason || "OAuth variables missing"}. Click to continue in demo mode.`;
      setAuthButtonState(button, enabled, reason);
    });
  } catch {
    apiAuthAvailable = false;
    providerStatusById = new Map();

    authButtons.forEach((button) => {
      setAuthButtonState(button, false, "OAuth API unavailable. Click to continue in demo mode.");
    });

    setAuthMessage("OAuth API unavailable. Demo login mode is enabled.", false);
  }
}

function showAuthenticatedApp(user) {
  authGate.classList.add("hidden");
  appShell.classList.remove("hidden");

  if (!user) return;

  const label = providerLabels[user.provider] || user.provider || "Social";

  sessionChip.classList.remove("hidden");
  sessionName.textContent = user.displayName || user.username || "Logged in";
  sessionProvider.textContent = user.isDemo ? `via ${label} (demo)` : `via ${label}`;

  if (user.avatarUrl) {
    sessionAvatar.src = user.avatarUrl;
    sessionAvatar.classList.remove("hidden");
  } else {
    sessionAvatar.classList.add("hidden");
    sessionAvatar.removeAttribute("src");
  }
}

function showLoginGate() {
  appShell.classList.add("hidden");
  authGate.classList.remove("hidden");
  sessionChip.classList.add("hidden");
  setAppMessage("");
}

function getStoredDemoSession() {
  const session = readStorageJson(STORAGE_KEYS.demoSession, null);
  return session && typeof session === "object" ? session : null;
}

function persistDemoSession(session) {
  writeStorageJson(STORAGE_KEYS.demoSession, session);
}

function clearDemoSession() {
  removeStorageKey(STORAGE_KEYS.demoSession);
}

function createDemoUser(provider) {
  const label = providerLabels[provider] || "Social";
  return {
    provider,
    providerUserId: `demo-${provider}`,
    username: `${provider}_affiliate`,
    displayName: `${label} Affiliate`,
    avatarUrl: null,
    email: null,
    isDemo: true
  };
}

async function checkSession() {
  try {
    const data = await requestJson("/api/auth/session");
    if (data.authenticated) return data;
  } catch {
    apiAuthAvailable = false;
  }

  const demoSession = getStoredDemoSession();
  if (demoSession) {
    return {
      authenticated: true,
      user: demoSession
    };
  }

  return { authenticated: false, user: null };
}

async function logout() {
  clearDemoSession();

  if (apiAuthAvailable) {
    try {
      await requestJson("/api/auth/logout", { method: "POST" });
    } catch {
      // Ignore logout endpoint failures in UI.
    }
  }

  showLoginGate();
  setAuthMessage("Logged out.", false);
}

function goToProviderAuth(provider) {
  window.location.href = `/api/auth/start?provider=${encodeURIComponent(provider)}`;
}

function signInWithDemo(provider, reason) {
  const demoUser = createDemoUser(provider);
  persistDemoSession(demoUser);
  showAuthenticatedApp(demoUser);
  setAuthMessage("");
  setAppMessage(`${reason} Signed in with ${providerLabels[provider] || provider} demo profile.`, false);
}

function handleAuthClick(button) {
  const provider = String(button.dataset.provider || "").toLowerCase();
  if (!provider) return;

  const providerLabel = providerLabels[provider] || provider;
  const isProviderEnabled = button.dataset.enabled === "true";

  if (isProviderEnabled) {
    setAuthMessage(`Redirecting to ${providerLabel}...`, false);
    goToProviderAuth(provider);
    return;
  }

  const status = providerStatusById.get(provider);
  const reason =
    status?.reason ||
    (apiAuthAvailable ? `${providerLabel} OAuth not configured.` : "OAuth API unavailable.");

  signInWithDemo(provider, reason);
}

const commissionText = (contract) => {
  if (contract.commissionType === "CPA") {
    return `$${contract.commissionValue} / conversion`;
  }
  if (contract.commissionType === "REV SHARE") {
    return `${contract.commissionValue}% rev share`;
  }
  return `$${contract.commissionValue} + rev share`;
};

function renderContracts() {
  campaignList.innerHTML = "";

  if (!contracts.length) {
    const emptyState = document.createElement("p");
    emptyState.className = "desc";
    emptyState.textContent = "No contracts yet. Switch to Company View to publish the first one.";
    campaignList.append(emptyState);
    return;
  }

  contracts.forEach((contract) => {
    const card = cardTemplate.content.firstElementChild.cloneNode(true);
    card.querySelector(".company").textContent = `${contract.companyName} ${contract.companyHandle}`;
    card.querySelector(".pill").textContent = contract.category;
    card.querySelector("h3").textContent = contract.title;
    card.querySelector(".desc").textContent = contract.description;
    card.querySelector(".commission").textContent = commissionText(contract);
    card.querySelector(".cookie").textContent = `${contract.cookieWindowDays}d cookie`;
    card.querySelector(".payout").textContent = `$${contract.monthlyPayoutCap} cap`;

    const applyButton = card.querySelector(".apply-btn");
    const hasApplied = appliedContractIds.has(contract.id);

    if (hasApplied) {
      applyButton.textContent = "Application Sent";
      applyButton.disabled = true;
    } else {
      applyButton.addEventListener("click", () => {
        appliedContractIds.add(contract.id);
        persistAppliedContractIds();
        renderContracts();
        setAppMessage(`Application sent to ${contract.companyName}.`, false);
      });
    }

    campaignList.append(card);
  });
}

function setPanel(role) {
  const isAffiliate = role === "affiliate";
  affiliatePanel.classList.toggle("hidden", !isAffiliate);
  companyPanel.classList.toggle("hidden", isAffiliate);
  affiliateTab.classList.toggle("active", isAffiliate);
  companyTab.classList.toggle("active", !isAffiliate);
  affiliateTab.setAttribute("aria-selected", String(isAffiliate));
  companyTab.setAttribute("aria-selected", String(!isAffiliate));
  writeStorageJson(STORAGE_KEYS.activePanel, isAffiliate ? "affiliate" : "company");
}

affiliateTab.addEventListener("click", () => setPanel("affiliate"));
companyTab.addEventListener("click", () => setPanel("company"));

contractForm.addEventListener("submit", (event) => {
  event.preventDefault();
  const data = new FormData(contractForm);

  const newContract = {
    id: `contract-${Date.now()}`,
    isSeed: false,
    companyName: "Your Company",
    companyHandle: "@yourbrand",
    title: String(data.get("title") || "").trim(),
    category: String(data.get("category") || "OTHER"),
    commissionType: String(data.get("commissionType") || "CPA"),
    commissionValue: Number(data.get("commissionValue")),
    cookieWindowDays: Number(data.get("cookieWindowDays")),
    monthlyPayoutCap: Number(data.get("monthlyPayoutCap")),
    targetRegion: String(data.get("targetRegion") || "").trim(),
    description: String(data.get("description") || "").trim()
  };

  if (
    !newContract.title ||
    !newContract.description ||
    !newContract.targetRegion ||
    !Number.isFinite(newContract.commissionValue) ||
    !Number.isFinite(newContract.cookieWindowDays) ||
    !Number.isFinite(newContract.monthlyPayoutCap)
  ) {
    setAppMessage("Please fill every contract field before publishing.", true);
    return;
  }

  contracts.unshift(newContract);
  persistPostedContracts();
  contractForm.reset();
  renderContracts();
  setPanel("affiliate");
  setAppMessage(`Contract "${newContract.title}" published and visible to affiliates.`, false);
});

authButtons.forEach((button) => {
  button.addEventListener("click", () => handleAuthClick(button));
});

logoutBtn.addEventListener("click", logout);

function restorePanelPreference() {
  const savedPanel = readStorageJson(STORAGE_KEYS.activePanel, "affiliate");
  setPanel(savedPanel === "company" ? "company" : "affiliate");
}

async function init() {
  contracts = loadContractsFromStorage();
  appliedContractIds = loadAppliedContractIds();

  renderContracts();
  restorePanelPreference();
  await loadProviderStatus();

  const { auth, authError } = getQueryStatus();
  if (authError) {
    setAuthMessage(decodeURIComponent(authError), true);
  } else if (auth === "success") {
    setAuthMessage("Login successful.", false);
  }

  const session = await checkSession();
  if (session.authenticated) {
    showAuthenticatedApp(session.user);
  } else {
    showLoginGate();
  }

  cleanAuthQueryParams();
}

init();
