const affiliateTab = document.getElementById("affiliateTab");
const companyTab = document.getElementById("companyTab");
const affiliatePanel = document.getElementById("affiliatePanel");
const companyPanel = document.getElementById("companyPanel");
const campaignList = document.getElementById("campaignList");
const contractForm = document.getElementById("contractForm");
const cardTemplate = document.getElementById("cardTemplate");

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

renderContracts();

