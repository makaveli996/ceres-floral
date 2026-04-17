{**
 * Purpose: Newsletter subscription section — two-column layout with email form and decorative image.
 * Used from: ps_emailsubscription module on displayHome / displayFooter hooks.
 * Inputs: $hookName, $value (prefilled email), $msg, $nw_error, $conditions, $id_module,
 *         $tc_newsletter_image (assigned by tc_newsletter via hookActionFrontControllerSetMedia).
 * Outputs: Newsletter banner HTML wrapped in container-md.
 * Side effects: Form posts to ps_emailsubscription front controller; GDPR via psgdpr hook.
 *}
<section class="newsletter-banner" id="blockEmailSubscription_{$hookName}">
  <div class="container-lg">
    <div class="newsletter-banner__inner">

      <div class="newsletter-banner__content">
        <h2 class="newsletter-banner__title">
          {l s='Zapisz się do newsletteru i odbierz 20% zniżki!' d='Shop.Theme.Global'}
        </h2>

        <form
          action="{$urls.current_url}#blockEmailSubscription_{$hookName}"
          method="post"
          class="newsletter-banner__form"
        >
          <div class="newsletter-banner__row">
            <div class="newsletter-banner__input-wrap">
              <input
                type="email"
                name="email"
                value="{$value}"
                placeholder="{l s='Adres e-mail' d='Shop.Forms.Labels'}"
                class="newsletter-banner__input"
                aria-label="{l s='Adres e-mail' d='Shop.Forms.Labels'}"
                required
              >
            </div>
            {include file='_partials/button.tpl'
              label={l s='Odbierz rabat' d='Shop.Theme.Actions'}
              btn_class='newsletter-banner__btn button--green'
              button_type='submit'
              button_name='submitNewsletter'
              icon_type='arrow-right'
            }
          </div>

          <input type="hidden" name="blockHookName" value="{$hookName}">
          <input type="hidden" name="action" value="0">

          {if $msg}
            <p class="newsletter-banner__alert{if $nw_error} newsletter-banner__alert--error{else} newsletter-banner__alert--success{/if}">
              {$msg}
            </p>
          {/if}

          <div class="newsletter-banner__gdpr">
            {if isset($id_module)}
              {hook h='displayGDPRConsent' id_module=$id_module}
            {/if}
            {if $conditions}
              <p class="newsletter-banner__conditions">{$conditions}</p>
            {/if}
            {hook h='displayNewsletterRegistration'}
          </div>

        </form>
      </div>

      {if isset($tc_newsletter_image) && $tc_newsletter_image}
        <div class="newsletter-banner__image" aria-hidden="true">
          <img src="{$tc_newsletter_image|escape:'html':'UTF-8'}" alt="">
        </div>
      {/if}

    </div>
  </div>
</section>
