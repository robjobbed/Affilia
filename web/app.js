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

const contracts = [
  {
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

function setAuthMessage(message, isError = false) {
  authMessage.textContent = message || "";
  authMessage.classList.toggle("error", Boolean(isError));
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

async function loadProviderStatus() {
  try {
    const data = await requestJson("/api/auth/providers");
    const providers = data.providers || [];

    providers.forEach((provider) => {
      const button = document.querySelector(`.auth-btn[data-provider="${provider.id}"]`);
      if (!button) return;

      button.disabled = !provider.enabled;
      if (!provider.enabled) {
        button.classList.add("disabled");
        button.title = provider.reason || `${provider.label} login is not configured`;
      } else {
        button.classList.remove("disabled");
        button.title = "";
      }
    });
  } catch {
    setAuthMessage("Unable to load provider config. Try again.", true);
  }
}

function showAuthenticatedApp(user) {
  authGate.classList.add("hidden");
  appShell.classList.remove("hidden");

  if (user) {
    sessionChip.classList.remove("hidden");
    sessionName.textContent = user.displayName || user.username || "Logged in";
    sessionProvider.textContent = `via ${providerLabels[user.provider] || user.provider}`;

    if (user.avatarUrl) {
      sessionAvatar.src = user.avatarUrl;
      sessionAvatar.classList.remove("hidden");
    } else {
      sessionAvatar.classList.add("hidden");
      sessionAvatar.removeAttribute("src");
    }
  }
}

function showLoginGate() {
  appShell.classList.add("hidden");
  authGate.classList.remove("hidden");
  sessionChip.classList.add("hidden");
}

async function checkSession() {
  try {
    const data = await requestJson("/api/auth/session");
    return data;
  } catch {
    return { authenticated: false, user: null };
  }
}

async function logout() {
  try {
    await requestJson("/api/auth/logout", { method: "POST" });
  } catch {
    // No-op on logout errors
  }
  showLoginGate();
  setAuthMessage("Logged out.", false);
}

function goToProviderAuth(provider) {
  window.location.href = `/api/auth/start?provider=${encodeURIComponent(provider)}`;
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

const renderContracts = () => {
  campaignList.innerHTML = "";

  contracts.forEach((contract) => {
    const card = cardTemplate.content.firstElementChild.cloneNode(true);
    card.querySelector(".company").textContent = `${contract.companyName} ${contract.companyHandle}`;
    card.querySelector(".pill").textContent = contract.category;
    card.querySelector("h3").textContent = contract.title;
    card.querySelector(".desc").textContent = contract.description;
    card.querySelector(".commission").textContent = commissionText(contract);
    card.querySelector(".cookie").textContent = `${contract.cookieWindowDays}d cookie`;
    card.querySelector(".payout").textContent = `$${contract.monthlyPayoutCap} cap`;
    card.querySelector(".apply-btn").addEventListener("click", () => {
      alert(`Application sent to ${contract.companyName}.`);
    });

    campaignList.append(card);
  });
};

const setPanel = (role) => {
  const isAffiliate = role === "affiliate";
  affiliatePanel.classList.toggle("hidden", !isAffiliate);
  companyPanel.classList.toggle("hidden", isAffiliate);
  affiliateTab.classList.toggle("active", isAffiliate);
  companyTab.classList.toggle("active", !isAffiliate);
  affiliateTab.setAttribute("aria-selected", String(isAffiliate));
  companyTab.setAttribute("aria-selected", String(!isAffiliate));
};

affiliateTab.addEventListener("click", () => setPanel("affiliate"));
companyTab.addEventListener("click", () => setPanel("company"));

contractForm.addEventListener("submit", (event) => {
  event.preventDefault();
  const data = new FormData(contractForm);

  const newContract = {
    companyName: "Your Company",
    companyHandle: "@yourbrand",
    title: String(data.get("title")),
    category: String(data.get("category")),
    commissionType: String(data.get("commissionType")),
    commissionValue: Number(data.get("commissionValue")),
    cookieWindowDays: Number(data.get("cookieWindowDays")),
    monthlyPayoutCap: Number(data.get("monthlyPayoutCap")),
    description: String(data.get("description"))
  };

  contracts.unshift(newContract);
  contractForm.reset();
  renderContracts();
  setPanel("affiliate");
});

authButtons.forEach((button) => {
  button.addEventListener("click", () => {
    if (button.disabled) return;
    goToProviderAuth(button.dataset.provider);
  });
});

logoutBtn.addEventListener("click", logout);

async function init() {
  renderContracts();
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
