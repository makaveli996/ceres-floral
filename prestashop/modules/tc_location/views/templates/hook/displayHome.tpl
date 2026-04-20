{**
 * Location section — displayHome hook output.
 * Layout: two columns — Google Maps iframe (left) + image slider + address + nav link (right).
 * JS:   data-tc-location-slider → _dev/js/custom/Sections/LocationSlider.js
 * SCSS: _dev/css/custom/sections/_location.scss (tc-location block)
 *}
<section class="tc-location" data-tc-location-slider>
  <div class="container-lg">
    <div class="tc-location__inner">

      {* ── Left: Google Maps iframe ── *}
      <div class="tc-location__map">
        {if $maps_iframe}
          <iframe
            src="{$maps_iframe|escape:'htmlall':'UTF-8'}"
            class="tc-location__map-frame"
            allowfullscreen=""
            loading="lazy"
            referrerpolicy="no-referrer-when-downgrade"
            title="{l s='Mapa lokalizacji' d='Modules.Tc_location.Shop'}"
          ></iframe>
        {/if}
      </div>

      {* ── Right: content ── *}
      <div class="tc-location__content">

        {if $title}
          <h2 class="tc-location__title">{$title|escape:'html':'UTF-8'}</h2>
        {/if}

        {* Image slider — only rendered when there are slides *}
        {if $tc_location_images|count > 0}
          <div class="tc-location__slider-wrap">
            <div
              class="splide tc-location__splide"
              aria-label="{l s='Zdjęcia showroom' d='Modules.Tc_location.Shop'}"
            >
              <div class="splide__track">
                <ul class="splide__list">
                  {foreach from=$tc_location_images item=slide}
                    {if $slide.image}
                      <li class="splide__slide">
                        <img
                          src="{$slide.image|escape:'html':'UTF-8'}"
                          alt="{l s='Zdjęcie showroom' d='Modules.Tc_location.Shop'}"
                          class="tc-location__slide-img"
                          loading="lazy"
                        >
                      </li>
                    {/if}
                  {/foreach}
                </ul>
              </div>
            </div>

            {* Single "next" arrow — only right navigation per design *}
            <button
              class="tc-slider-arrows__btn tc-location__arrow"
              type="button"
              data-slider-next
              aria-label="{l s='Następne zdjęcie' d='Shop.Theme.Catalog'}"
            >
              <span class="tc-slider-arrows__icon" aria-hidden="true">
                {include file='_partials/icon-chevron.tpl' direction='right'}
              </span>
            </button>
          </div>
        {/if}

        {* Address + Google Maps navigation link *}
        <div class="tc-location__address-wrap">
          {if $address}
            <p class="tc-location__address">{$address|escape:'html':'UTF-8'}</p>
          {/if}

        {if $maps_url}
          <a
            href="{$maps_url|escape:'html':'UTF-8'}"
            class="tc-location__maps-link"
            target="_blank"
            rel="noopener noreferrer"
          >
            {l s='Nawiguj w Google Maps' d='Modules.Tc_location.Shop'}
            <svg class="tc-location__maps-link-icon" width="7" height="10" viewBox="0 0 7 10" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M5.76371 4.23839L1.84177 0.316456C1.41983 -0.105485 0.738396 -0.105485 0.316455 0.316456C-0.105485 0.738396 -0.105485 1.41983 0.316455 1.84177L3.47679 5L0.316454 8.15822C-0.105487 8.58016 -0.105487 9.2616 0.316454 9.68354C0.738394 10.1055 1.41983 10.1055 1.84177 9.68354L5.76371 5.7616C6.18354 5.34177 6.18354 4.65823 5.76371 4.23839Z" fill="#79897E"/>
            </svg>
          </a>
        {/if}
        </div>

      </div>{* /tc-location__content *}

    </div>{* /tc-location__inner *}
  </div>
</section>
