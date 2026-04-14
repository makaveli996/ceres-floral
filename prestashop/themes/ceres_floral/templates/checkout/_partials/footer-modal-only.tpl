{**
 * Checkout-only modal (#modal / .js-checkout-modal) for opening CMS pages (e.g. TOS) without leaving checkout.
 * Used from checkout.tpl together with theme _partials/footer.tpl; core checkout JS targets this markup.
 *}
<div class="modal fade js-checkout-modal" id="modal">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <button type="button" class="close" data-dismiss="modal" aria-label="{l s='Close' d='Shop.Theme.Global'}">
        <span aria-hidden="true">&times;</span>
      </button>
      <div class="js-modal-content"></div>
    </div>
  </div>
</div>
