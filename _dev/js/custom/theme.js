import initMenuSticky from "./Sections/MenuSticky";
import initMobileHeader from "./Sections/MobileHeader";
import initHomePromoSlider from "./Sections/HomePromoSlider";
import initProductSlider from "./Sections/ProductSlider";

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
