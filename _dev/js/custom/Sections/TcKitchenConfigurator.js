/**
 * Kitchen configurator FO interactions.
 * Enables card selected state and single-choice behavior in configured groups.
 * Handles radio-button assembly cards, switch toggles, and file input label.
 */
function syncCardState(input) {
  const card = input.closest(".tc-kcfg-card");
  if (!card) return;
  card.classList.toggle("is-selected", input.checked);
}

function initSingleChoice(group) {
  if (group.getAttribute("data-single-choice") !== "1") return;
  group.querySelectorAll('input[type="checkbox"]').forEach((input) => {
    input.addEventListener("change", () => {
      if (!input.checked) return;
      group.querySelectorAll('input[type="checkbox"]').forEach((other) => {
        if (other !== input) other.checked = false;
        syncCardState(other);
      });
      syncCardState(input);
    });
  });
}

function initRadioCards(root) {
  root.querySelectorAll('input[type="radio"]').forEach((radio) => {
    syncCardState(radio);
    radio.addEventListener("change", () => {
      const name = radio.getAttribute("name");
      root.querySelectorAll(`input[type="radio"][name="${name}"]`).forEach((r) => {
        syncCardState(r);
      });
    });
  });
}

function initSwitchToggles(root) {
  root.querySelectorAll(".tc-kcfg-card__flag").forEach((flag) => {
    flag.addEventListener("click", (e) => {
      e.preventDefault();
      e.stopPropagation();
      const sw = flag.querySelector(".tc-kcfg-switch input");
      if (!sw) return;
      sw.checked = !sw.checked;
      const card = flag.closest(".tc-kcfg-card");
      if (card) card.classList.toggle("is-flagged", sw.checked);
    });
  });
}

function initAjaxSubmit(root) {
  const form = root.querySelector("#tc-kcfg-form");
  if (!form) return;

  const ajaxUrl = form.getAttribute("data-tc-kcfg-ajax-url");
  if (!ajaxUrl) return;

  const messagesEl = document.getElementById("tc-kcfg-form-messages");
  const submitBtn = form.querySelector('button[name="submitTcKitchenConfigurator"]');

  form.addEventListener("submit", async (e) => {
    e.preventDefault();

    if (submitBtn) {
      submitBtn.disabled = true;
      submitBtn.setAttribute("aria-busy", "true");
    }
    if (messagesEl) messagesEl.innerHTML = "";

    const formData = new FormData(form);
    formData.append("submitTcKitchenConfigurator", "1");

    try {
      const res = await fetch(ajaxUrl, {
        method: "POST",
        body: formData,
        headers: {
          Accept: "application/json",
          "X-Requested-With": "XMLHttpRequest",
        },
      });

      const rawText = await res.text();
      let data = {};
      try {
        data = JSON.parse(rawText);
      } catch (_) {
        const first = rawText.indexOf("{");
        const last = rawText.lastIndexOf("}");
        if (first !== -1 && last > first) {
          data = JSON.parse(rawText.slice(first, last + 1));
        }
      }

      if (data.success) {
        if (messagesEl) {
          messagesEl.innerHTML = renderAlert(data.messages || [], false);
          messagesEl.scrollIntoView({ behavior: "smooth", block: "nearest" });
        }
        form.reset();
        root.querySelectorAll(".tc-kcfg-card").forEach((card) => {
          card.classList.remove("is-selected", "is-flagged");
        });
        const fileNameEl = root.querySelector(".tc-kcfg-attachment__file-name");
        if (fileNameEl) {
          fileNameEl.textContent = "";
          fileNameEl.classList.remove("is-visible");
        }
      } else {
        const errMsgs =
          Array.isArray(data.messages) && data.messages.length
            ? data.messages
            : ["Nie udało się wysłać formularza. Spróbuj ponownie."];
        if (messagesEl) {
          messagesEl.innerHTML = renderAlert(errMsgs, true);
          messagesEl.scrollIntoView({ behavior: "smooth", block: "nearest" });
        }
      }
    } catch (_) {
      if (messagesEl) {
        messagesEl.innerHTML = renderAlert(
          ["Nie udało się wysłać formularza. Spróbuj ponownie."],
          true
        );
      }
    } finally {
      if (submitBtn) {
        submitBtn.disabled = false;
        submitBtn.removeAttribute("aria-busy");
      }
    }
  });
}

function renderAlert(messages, isError) {
  if (!Array.isArray(messages) || !messages.length) return "";
  const list = messages.map((m) => `<li>${escapeHtml(m)}</li>`).join("");
  const cls = isError ? "tc-kcfg-alert--error" : "tc-kcfg-alert--success";
  return `<div class="tc-kcfg-alert ${cls}"><ul>${list}</ul></div>`;
}

function escapeHtml(str) {
  const div = document.createElement("div");
  div.textContent = str;
  return div.innerHTML;
}

export default function initTcKitchenConfigurator() {
  const root = document.querySelector(".tc-kitchen-configurator");
  if (!root) return;

  root.querySelectorAll(".tc-kcfg-group").forEach((group) => {
    initSingleChoice(group);
    group.querySelectorAll('input[type="checkbox"]').forEach((input) => {
      syncCardState(input);
      input.addEventListener("change", () => syncCardState(input));
    });
  });

  initRadioCards(root);
  initSwitchToggles(root);
  initAjaxSubmit(root);

  const fileInput = root.querySelector('input[type="file"][name="kcfg_attachment"]');
  const fileName = root.querySelector(".tc-kcfg-attachment__file-name");
  if (fileInput && fileName) {
    fileInput.addEventListener("change", () => {
      if (fileInput.files && fileInput.files[0]) {
        fileName.textContent = fileInput.files[0].name;
        fileName.classList.add("is-visible");
      } else {
        fileName.textContent = "";
        fileName.classList.remove("is-visible");
      }
    });
  }
}
