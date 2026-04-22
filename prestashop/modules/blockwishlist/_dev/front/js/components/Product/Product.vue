<!--**
 * Copyright since 2007 PrestaShop SA and Contributors
 * PrestaShop is an International Registered Trademark & Property of PrestaShop SA
 *
 * NOTICE OF LICENSE
 *
 * This source file is subject to the Academic Free License version 3.0
 * that is bundled with this package in the file LICENSE.md.
 * It is also available through the world-wide-web at this URL:
 * https://opensource.org/licenses/AFL-3.0
 * If you did not receive a copy of the license, please send an email
 * to license@prestashop.com so we can send you a copy immediately.
 *
 * @author    PrestaShop SA and Contributors <contact@prestashop.com>
 * @copyright Since 2007 PrestaShop SA and Contributors
 * @license   https://opensource.org/licenses/AFL-3.0 Academic Free License version 3.0
 *-->
<template>
  <div class="wishlist-tile">
    <div
      v-if="product.html_tile"
      class="wishlist-tile__html"
      v-html="product.html_tile"
    />
    <div
      v-else
      class="wishlist-tile__fallback"
    >
      <a
        :href="productUrl"
        class="wishlist-tile__fallback-name"
      >{{ product.name }}</a>
    </div>

    <div
      v-if="!isShare"
      class="wishlist-tile__remove"
    >
      <button
        type="button"
        class="button"
        :disabled="removeInProgress"
        @click="removeFromList"
      >
        {{ removeFromListLabel }}
      </button>
    </div>
  </div>
</template>

<script>
  import EventBus from '@components/EventBus';
  import removeFromWishlistUrl from 'removeFromWishlistUrl';

  /**
   * Kafelek: HTML (Smarty) + serce/QuickAdd z motywu. Pod kafelkiem: tylko „usuń z listy” (to samo API co klik w serce na widoku listy).
   */
  export default {
    name: 'Product',
    props: {
      product: {
        type: Object,
        required: true,
        default: null,
      },
      listId: {
        type: Number,
        required: true,
        default: null,
      },
      listName: {
        type: String,
        required: true,
        default: '',
      },
      isShare: {
        type: Boolean,
        required: false,
        default: false,
      },
      customizeText: {
        type: String,
        required: true,
        default: 'Customize',
      },
      quantityText: {
        type: String,
        required: true,
        default: 'Quantity',
      },
      addToCart: {
        type: String,
        required: true,
      },
      removeFromListLabel: {
        type: String,
        required: true,
        default: 'Usuń z listy',
      },
      status: {
        type: Number,
        required: false,
        default: 0,
      },
      hasControls: {
        type: Boolean,
        required: false,
        default: true,
      },
    },
    data() {
      return {
        removeInProgress: false,
      };
    },
    computed: {
      productUrl() {
        return this.product.canonical_url || this.product.url || '#';
      },
    },
    methods: {
      buildRemoveUrl() {
        const u = removeFromWishlistUrl;
        if (!u) {
          return '';
        }
        const idP = this.product.id_product;
        const listId = this.listId;
        const idA = this.product.id_product_attribute || 0;
        const p = (k, v) => `params[${encodeURIComponent(k)}]=${encodeURIComponent(v)}`;
        const q = [p('id_product', idP), p('idWishList', listId), p('id_product_attribute', idA)].join('&');
        return `${u}${u.includes('?') ? '&' : '?'}${q}`;
      },
      async removeFromList() {
        if (this.removeInProgress) {
          return;
        }
        const fullUrl = this.buildRemoveUrl();
        if (!fullUrl) {
          return;
        }
        this.removeInProgress = true;
        try {
          const response = await fetch(fullUrl, {
            method: 'POST',
            headers: {Accept: 'application/json'},
          });
          const removeResp = await response.json();
          if (!removeResp || !removeResp.success) {
            return;
          }
          EventBus.$emit('refetchList');
        } catch (e) {
          /* eslint-disable no-console */
          console.error('[wishlist] removeFromList', e);
        } finally {
          this.removeInProgress = false;
        }
      },
    },
  };
</script>

<style lang="scss" type="text/scss">
  .wishlist-tile {
    min-width: 0;
    display: flex;
    flex-direction: column;
    gap: 0.75rem;

    &__html {
      min-width: 0;
    }

    &__remove {
      margin-top: 0.25rem;
    }
  }
</style>
