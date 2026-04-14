import initMenuSticky from "./Sections/MenuSticky";
import initMobileHeader from "./Sections/MobileHeader";
import initHomePromoSlider from "./Sections/HomePromoSlider";
import initProductSlider from "./Sections/ProductSlider";
import initBestsellersSlider from "./Sections/BestsellersSlider";

function runWhenReady(fn) {
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", fn);
  } else {
    fn();
  }
}

runWhenReady(initMenuSticky);
runWhenReady(initMobileHeader);
runWhenReady(initHomePromoSlider);
runWhenReady(initProductSlider);
runWhenReady(initBestsellersSlider);
