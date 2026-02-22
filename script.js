document.addEventListener('DOMContentLoaded', () => {

  document.querySelectorAll('[data-carousel]').forEach(carousel => {
    const viewport = carousel.querySelector('.carousel-viewport');
    const track = carousel.querySelector('.carousel-track');
    const slides = carousel.querySelectorAll('.carousel-slide');
    const counter = carousel.querySelector('.carousel-counter .current');
    const prevBtn = carousel.querySelector('.carousel-btn.prev');
    const nextBtn = carousel.querySelector('.carousel-btn.next');
    const dotsContainer = carousel.querySelector('.carousel-dots');
    const total = slides.length;
    let current = 0;
    let dragStartX = 0;
    let dragOffset = 0;
    let isDragging = false;

    for (let i = 0; i < total; i++) {
      const dot = document.createElement('button');
      dot.className = 'carousel-dot' + (i === 0 ? ' active' : '');
      dot.setAttribute('aria-label', `Go to slide ${i + 1}`);
      dot.addEventListener('click', () => goTo(i));
      dotsContainer.appendChild(dot);
    }
    const dots = dotsContainer.querySelectorAll('.carousel-dot');

    function goTo(index) {
      current = ((index % total) + total) % total;
      track.style.transform = `translateX(-${current * 100}%)`;
      if (counter) counter.textContent = current + 1;
      dots.forEach((d, i) => d.classList.toggle('active', i === current));
    }

    prevBtn.addEventListener('click', () => goTo(current - 1));
    nextBtn.addEventListener('click', () => goTo(current + 1));

    function onPointerDown(e) {
      if (e.button && e.button !== 0) return;
      isDragging = true;
      dragStartX = e.clientX || e.touches[0].clientX;
      dragOffset = 0;
      track.classList.add('dragging');
    }

    function onPointerMove(e) {
      if (!isDragging) return;
      const clientX = e.clientX || (e.touches && e.touches[0].clientX);
      if (clientX == null) return;
      dragOffset = clientX - dragStartX;
      const pct = (dragOffset / viewport.offsetWidth) * 100;
      track.style.transform = `translateX(calc(-${current * 100}% + ${pct}%))`;
    }

    function onPointerUp() {
      if (!isDragging) return;
      isDragging = false;
      track.classList.remove('dragging');
      const threshold = viewport.offsetWidth * 0.15;
      if (dragOffset < -threshold) {
        goTo(current + 1);
      } else if (dragOffset > threshold) {
        goTo(current - 1);
      } else {
        goTo(current);
      }
    }

    viewport.addEventListener('mousedown', onPointerDown);
    viewport.addEventListener('touchstart', onPointerDown, { passive: true });
    window.addEventListener('mousemove', onPointerMove);
    window.addEventListener('touchmove', onPointerMove, { passive: true });
    window.addEventListener('mouseup', onPointerUp);
    window.addEventListener('touchend', onPointerUp);

    carousel.addEventListener('keydown', e => {
      if (e.key === 'ArrowLeft') goTo(current - 1);
      if (e.key === 'ArrowRight') goTo(current + 1);
    });
  });

  const observer = new IntersectionObserver(entries => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.08, rootMargin: '0px 0px -40px 0px' });

  document.querySelectorAll('.content-section, .contact-section').forEach(el => {
    observer.observe(el);
  });

});
