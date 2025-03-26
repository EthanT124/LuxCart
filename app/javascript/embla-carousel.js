import EmblaCarousel from "embla-carousel";

document.addEventListener("DOMContentLoaded", () => {
  const emblaNode = document.querySelector(".embla");
  const options = { loop: true };
  if (emblaNode) {
    EmblaCarousel(emblaNode, options);
  }
});
