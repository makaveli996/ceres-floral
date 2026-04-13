/**
 * TcVideoSection — custom play overlay; visibility synced with video play/pause/ended.
 * Play from overlay or native controls: overlay hidden. Pause/ended: overlay visible.
 * Used when [data-tc-videosection] is present. Called from _dev/js/custom/theme.js.
 */
function initTcVideoSection() {
  const section = document.querySelector("[data-tc-videosection]");
  if (!section) return;

  const video = section.querySelector(".tc-videosection__video");
  const overlay = section.querySelector(".tc-videosection__play-overlay");
  if (!video || !overlay) return;

  function setOverlayVisible(visible) {
    if (visible) {
      section.classList.remove("tc-videosection--playing");
      video.removeAttribute("controls");
    } else {
      section.classList.add("tc-videosection--playing");
      video.setAttribute("controls", "");
    }
  }

  // Sync overlay with actual playback state (native controls or our button)
  video.addEventListener("play", () => setOverlayVisible(false));
  video.addEventListener("pause", () => setOverlayVisible(true));
  video.addEventListener("ended", () => {
    if (!video.loop) setOverlayVisible(true);
  });

  // Initial state
  setOverlayVisible(video.paused);

  const playBtn = section.querySelector(".tc-videosection__play-btn");
  if (playBtn) {
    playBtn.addEventListener("click", () => video.play());
  }
}

export default initTcVideoSection;
