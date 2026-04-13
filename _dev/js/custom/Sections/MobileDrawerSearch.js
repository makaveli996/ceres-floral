/**
 * Mobile drawer search — klonuje widżet wyszukiwarki (#search_widget) do drawera
 * (#mobile_drawer_search) na widokach mobilnych i inicjuje autocomplete na klonie
 * (moduł ps_searchbar wiąże sugestie tylko z #search_widget).
 * Używane w: theme (header drawera).
 */

const MOBILE_BREAKPOINT = 992;

function isMobile() {
  return window.matchMedia(`(max-width: ${MOBILE_BREAKPOINT - 1}px)`).matches;
}

function initAutocompleteOnClone() {
  const $ = window.jQuery || window.$;
  if (!$ || !$.fn.psBlockSearchAutocomplete) return false;

  const $clone = $("#mobile_search_widget");
  if (!$clone.length) return false;

  const $input = $clone.find("input[type=text]");
  const searchURL = $clone.attr("data-search-controller-url");
  const $clearBtn = $clone.find("i.clear");
  if (!$input.length || !searchURL) return false;

  $input.psBlockSearchAutocomplete({
    appendTo: "#mobile_search_widget",
    position: { my: "left bottom", at: "left top", of: $input[0], collision: "none" },
    source: function (query, response) {
      $.post(searchURL, { s: query.term, resultsPerPage: 10 }, null, "json")
        .then(function (resp) {
          const products = resp && resp.products ? resp.products : [];
          response(products);
        })
        .fail(function () {
          response([]);
        });
    },
    select: function (event, ui) {
      if (ui.item && ui.item.url) window.location.href = ui.item.url;
    },
  });
  $input.psBlockSearchAutocomplete("widget").addClass("searchbar-autocomplete");

  $clearBtn.on("click", function () {
    $input.val("");
    $clearBtn.hide();
  });
  $input.on("keyup", function () {
    $clearBtn.toggle($input.val() !== "" && isMobile());
  });
  return true;
}

export default function initMobileDrawerSearch() {
  const drawerSearch = document.getElementById("mobile_drawer_search");
  const sourceWidget = document.getElementById("search_widget");
  if (!drawerSearch || !sourceWidget) return;

  function cloneAndInit() {
    if (!isMobile()) return;
    const hasClone = !!drawerSearch.querySelector(".search-widgets");
    if (hasClone) {
      if (!drawerSearch.querySelector("#mobile_search_widget input[data-autocomplete-inited]")) {
        const done = initAutocompleteOnClone();
        if (done) drawerSearch.querySelector("#mobile_search_widget input")?.setAttribute("data-autocomplete-inited", "1");
      }
      return;
    }

    const clone = sourceWidget.cloneNode(true);
    clone.id = "mobile_search_widget";
    clone.setAttribute("aria-label", "Szukaj");
    drawerSearch.appendChild(clone);

    const tryInit = (attempt) => {
      if (initAutocompleteOnClone()) {
        drawerSearch.querySelector("#mobile_search_widget input")?.setAttribute("data-autocomplete-inited", "1");
        return;
      }
      if (attempt < 50) setTimeout(() => tryInit(attempt + 1), 100);
    };
    setTimeout(() => tryInit(0), 100);
  }

  setTimeout(() => {
    cloneAndInit();
    window.matchMedia(`(max-width: ${MOBILE_BREAKPOINT - 1}px)`).addEventListener("change", cloneAndInit);
  }, 0);
}
