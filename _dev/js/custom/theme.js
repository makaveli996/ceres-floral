import initBannerTabs from "./Sections/BannerTabs";
import initFooterBackToTop from "./Sections/FooterBackToTop";
import initMenuSticky from "./Sections/MenuSticky";
import initMobileDrawerSearch from "./Sections/MobileDrawerSearch";
import initProductSlider from "./Sections/ProductSlider";
import initTcCollections from "./Sections/TcCollections";
import initTcCompanyHistory from "./Sections/TcCompanyHistory";
import initTcContact from "./Sections/TcContact";
import initTcFaq from "./Sections/TcFaq";
import initTcInspirationsSlider from "./Sections/TcInspirationsSlider";
import initTcDesignersSlider from "./Sections/TcDesignersSlider";
import initTcDesignerRegister from "./Sections/TcDesignerRegister";
import initTcStatsCounter from "./Sections/TcStatsCounter";
import initTcTestimonialsSlider from "./Sections/TcTestimonialsSlider";
import initTcProcessTabs from "./Sections/TcProcessTabs";
import initTcVideoSection from "./Sections/TcVideoSection";
import initTcKitchenConfigurator from "./Sections/TcKitchenConfigurator";
import initBlogTipsFilter from "./Sections/BlogTipsFilter";
import initBlogInspirationsFilter from "./Sections/BlogInspirationsFilter";
import initPostInspiration from "./Sections/PostInspiration";
import initPdpGallery from "./Sections/PdpGallery";
import initPdpVariants from "./Sections/PdpVariants";
import initPdpAttributePhotoTooltip from "./Sections/PdpAttributePhotoTooltip";
import initPdpAvailability from "./Sections/PdpAvailability";
import initPdpTabs from "./Sections/PdpTabs";
import initPdpSupportAccordion from "./Sections/PdpSupportAccordion";
import initFurnitureComparisonTable from "./Sections/FurnitureComparisonTable";
import initTcCollectionPages from "./Sections/TcCollectionPages";

function runWhenReady(fn) {
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", fn);
  } else {
    fn();
  }
}

runWhenReady(initBannerTabs);
runWhenReady(initFooterBackToTop);
runWhenReady(initMenuSticky);
runWhenReady(initMobileDrawerSearch);
runWhenReady(initProductSlider);
runWhenReady(initTcCollections);
runWhenReady(initTcCompanyHistory);
runWhenReady(initTcContact);
runWhenReady(initTcFaq);
runWhenReady(initTcInspirationsSlider);
runWhenReady(initTcDesignersSlider);
runWhenReady(initTcDesignerRegister);
runWhenReady(initTcStatsCounter);
runWhenReady(initTcProcessTabs);
runWhenReady(initTcTestimonialsSlider);
runWhenReady(initTcVideoSection);
runWhenReady(initTcKitchenConfigurator);
runWhenReady(initBlogTipsFilter);
runWhenReady(initBlogInspirationsFilter);
runWhenReady(initPostInspiration);
runWhenReady(initPdpGallery);
runWhenReady(initPdpVariants);
runWhenReady(initPdpAttributePhotoTooltip);
runWhenReady(initPdpAvailability);
runWhenReady(initPdpTabs);
runWhenReady(initPdpSupportAccordion);
runWhenReady(initFurnitureComparisonTable);
runWhenReady(initTcCollectionPages);
