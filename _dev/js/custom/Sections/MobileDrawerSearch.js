import $ from "jquery";

function normalizeProductsPayload(resp) {
  if (!resp) return [];
  if (Array.isArray(resp)) return resp;
  if (Array.isArray(resp.products)) return resp.products;
  if (Array.isArray(resp.result)) return resp.result;
  if (resp.products && typeof resp.products === "object") {
    return Object.values(resp.products);
  }
  return [];
}

function toAutocompleteItem(product) {
  if (typeof product === "string") {
    return {
      name: product,
      label: product,
      value: product,
    };
  }

  const name = resolveProductName(product);
  const label = name || product?.label || product?.value || "Produkt";

  return {
    ...product,
    name: name || label,
    label,
    value: label,
  };
}

function resolveProductName(product) {
  if (typeof product === "string") {
    return product.trim();
  }

  const rawName =
    product?.name ??
    product?.label ??
    product?.value ??
    product?.pname ??
    product?.cname ??
    product?.title ??
    "";

  if (typeof rawName === "string") {
    return rawName.trim();
  }

  if (rawName && typeof rawName === "object") {
    const firstStringValue = Object.values(rawName).find(
      (value) => typeof value === "string" && value.trim() !== "",
    );
    return firstStringValue ? firstStringValue.trim() : "";
  }

  return "";
}

function buildAutocompleteSource(searchURL) {
  return function source(request, response) {
    $.post(
      searchURL,
      {
        s: request.term,
        resultsPerPage: 10,
      },
      null,
      "json",
    )
      .then((resp) => {
        response(normalizeProductsPayload(resp).map(toAutocompleteItem));
      })
      .fail(() => response([]));
  };
}

function renderItem(ul, product) {
  const fallbackImage = window.prestashop?.urls?.no_picture_image;
  const image = product.cover || fallbackImage;
  const imageUrl = image?.bySize?.small_default?.url || "";
  const productName = resolveProductName(product) || "Produkt";
  const $image = imageUrl
    ? $(`<img class="autocomplete-thumbnail" src="${imageUrl}">`)
    : $("<span></span>");

  return $("<li>")
    .append(
      $("<a>")
        .append($image)
        .append($("<span>").text(productName).addClass("product")),
    )
    .appendTo(ul);
}

export default function initMobileDrawerSearch() {
  const $wrapper = $(".mobile-drawer-search");
  const $input = $wrapper.find(".mobile-drawer-search__input");
  if (!$wrapper.length || !$input.length) return;

  const searchURL =
    $wrapper.attr("data-search-controller-url") ||
    $wrapper.find("form").attr("action");
  if (!searchURL) return;

  const tryInit = () => {
    if (!$.ui || !$.ui.autocomplete || typeof $input.autocomplete !== "function") {
      return false;
    }
    if ($input.data("mobile-autocomplete-init")) {
      return true;
    }

    $input.autocomplete({
      source: buildAutocompleteSource(searchURL),
      minLength: 2,
      appendTo: $wrapper,
      position: {
        my: "left top",
        at: "left bottom",
        of: $input,
      },
      select(event, ui) {
        if (ui?.item?.url) {
          window.location.href = ui.item.url;
        }
      },
      open() {
        const $menu = $input.autocomplete("widget");
        $menu
          .addClass("searchbar-autocomplete")
          .css("width", `${$input.outerWidth()}px`);
      },
    });

    const autocompleteInstance =
      $input.data("ui-autocomplete") || $input.data("autocomplete");
    if (autocompleteInstance) {
      autocompleteInstance._renderItem = renderItem;
    }

    $input.data("mobile-autocomplete-init", true);
    return true;
  };

  if (tryInit()) return;

  let attempts = 0;
  const interval = window.setInterval(() => {
    attempts += 1;
    if (tryInit() || attempts >= 20) {
      window.clearInterval(interval);
    }
  }, 200);
}
