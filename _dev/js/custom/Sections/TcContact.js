/**
 * Contact form (tc_contact) — AJAX submit, validation feedback, preserve values on error.
 * Binds to #tc-contact-form when data-tc-contact-ajax-url is set. Used from _dev/js/custom/theme.js.
 */
function initTcContact() {
  const form = document.getElementById("tc-contact-form");
  if (!form) return;

  const ajaxUrl = form.getAttribute("data-tc-contact-ajax-url");
  if (!ajaxUrl) return;

  const messagesEl = document.getElementById("tc-contact-form-messages");
  const submitBtn = form.querySelector('button[name="submitTcContactForm"]');

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
          } catch (e) {
            const first = rawText.indexOf("{");
            const last = rawText.lastIndexOf("}");
            if (first !== -1 && last > first) {
              data = JSON.parse(rawText.slice(first, last + 1));
            } else {
              throw e;
            }
          }
        }
      } catch (_) {
        if (messagesEl) {
          messagesEl.innerHTML = renderAlert(["Nie udało się wysłać formularza. Spróbuj ponownie."], true);
        }
        return;
      }

      if (data.success) {
        if (messagesEl) {
          messagesEl.innerHTML = renderAlert(data.messages || [], false);
        }
        form.reset();
        if (form.closest(".tc-contact")) {
          const firstInput = form.querySelector("input:not([type=hidden]):not([type=text][name=tc_contact_url])");
          if (firstInput) firstInput.focus();
        }
      } else {
        const errMessages = Array.isArray(data.messages) && data.messages.length
          ? data.messages
          : ["Nie udało się wysłać formularza. Spróbuj ponownie."];
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
  const alertClass = isError ? "tc-contact__alert--error" : "tc-contact__alert--success";
  return `<div class="tc-contact__alert ${alertClass}"><ul>${list}</ul></div>`;
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
  set("tc_contact_subject", values.subject);
  set("tc_contact_full_name", values.full_name);
  set("tc_contact_company_vat", values.company_vat);
  set("tc_contact_email", values.email);
  set("tc_contact_phone", values.phone);
  const msg = form.querySelector('[name="tc_contact_message"]');
  if (msg && values.message != null) msg.value = values.message;
}

export default initTcContact;
