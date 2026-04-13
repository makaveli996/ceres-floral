/**
 * Designer registration form (tc_designerregister) — AJAX submit, validation feedback, preserve values on error.
 * Binds to #tc-designerregister-form when data-tc-designerregister-ajax-url is set. Used from _dev/js/custom/theme.js.
 */
function initTcDesignerRegister() {
  const form = document.getElementById("tc-designerregister-form");
  if (!form) return;

  const ajaxUrl = form.getAttribute("data-tc-designerregister-ajax-url");
  if (!ajaxUrl) return;

  const messagesEl = document.getElementById("tc-designerregister-form-messages");
  const submitBtn = form.querySelector('button[name="submitTcDesignerRegisterForm"]');

  form.addEventListener("submit", async (e) => {
    e.preventDefault();

    if (submitBtn) {
      submitBtn.disabled = true;
      submitBtn.setAttribute("aria-busy", "true");
    }

    if (messagesEl) {
      messagesEl.innerHTML = "";
    }

    const formData = new FormData(form);

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
        if (rawText) {
          try {
            data = JSON.parse(rawText);
          } catch (err) {
            const first = rawText.indexOf("{");
            const last = rawText.lastIndexOf("}");
            if (first !== -1 && last > first) {
              data = JSON.parse(rawText.slice(first, last + 1));
            } else {
              throw err;
            }
          }
        }
      } catch (_) {
        if (messagesEl) {
          messagesEl.innerHTML = renderAlert(
            ["Nie udało się wysłać formularza. Spróbuj ponownie."],
            true
          );
        }
        return;
      }

      if (data.success) {
        if (messagesEl) {
          messagesEl.innerHTML = renderAlert(data.messages || [], false);
        }
        form.reset();
        const section = form.closest(".tc-designerregister");
        if (section) {
          const firstInput = form.querySelector(
            'input:not([type=hidden]):not([type=password]):not([name="tc_designerregister_url"])'
          );
          if (firstInput) firstInput.focus();
        }
      } else {
        const errMessages =
          Array.isArray(data.messages) && data.messages.length
            ? data.messages
            : ["Nie udało się utworzyć konta. Spróbuj ponownie."];
        if (messagesEl) {
          messagesEl.innerHTML = renderAlert(errMessages, true);
        }
        if (data.form_values) {
          setFormValues(form, data.form_values);
        }
      }
    } catch (_) {
      if (messagesEl) {
        messagesEl.innerHTML = renderAlert(
          ["Nie udało się utworzyć konta. Spróbuj ponownie."],
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
  const alertClass = isError
    ? "tc-designerregister__alert--error"
    : "tc-designerregister__alert--success";
  return `<div class="tc-designerregister__alert ${alertClass}"><ul>${list}</ul></div>`;
}

function escapeHtml(str) {
  const div = document.createElement("div");
  div.textContent = str;
  return div.innerHTML;
}

function setFormValues(form, values) {
  if (!form || !values) return;
  const set = (name, value) => {
    const field = form.querySelector(`[name="${name}"]`);
    if (field && value != null) field.value = value;
  };
  set("tc_designerregister_company_nip", values.company_name_or_nip);
  set("tc_designerregister_social_website", values.social_profile_or_website);
  set("tc_designerregister_full_name", values.full_name);
  set("tc_designerregister_email", values.email);
  set("tc_designerregister_phone", values.phone);
  // passwd and passwd_confirm are not repopulated for security
}

export default initTcDesignerRegister;
