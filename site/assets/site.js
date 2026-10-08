/* PULSE FULFILMENT — shared site behaviours */
(function () {
  'use strict';

  /* Sticky header shadow */
  const header = document.querySelector('.site-header');
  if (header) {
    const onScroll = () => header.classList.toggle('scrolled', window.scrollY > 8);
    onScroll();
    window.addEventListener('scroll', onScroll, { passive: true });
  }

  /* Scroll reveal */
  const revealEls = document.querySelectorAll('.reveal');
  if ('IntersectionObserver' in window && revealEls.length) {
    const io = new IntersectionObserver((entries) => {
      entries.forEach((e) => {
        if (e.isIntersecting) { e.target.classList.add('in'); io.unobserve(e.target); }
      });
    }, { threshold: 0, rootMargin: '0px 0px -6% 0px' });
    revealEls.forEach((el) => io.observe(el));

    /* Reveal anything already in view on load (covers harnesses/no-scroll) */
    const revealInView = () => {
      const vh = window.innerHeight || document.documentElement.clientHeight;
      revealEls.forEach((el) => {
        const r = el.getBoundingClientRect();
        if (r.top < vh * 0.96 && r.bottom > 0) el.classList.add('in');
      });
    };
    window.addEventListener('load', revealInView);
    revealInView();
    /* Safety net: never leave content permanently hidden */
    setTimeout(() => revealEls.forEach((el) => el.classList.add('in')), 2200);
  } else {
    revealEls.forEach((el) => el.classList.add('in'));
  }

  /* Count-up stats */
  const fmt = (n, dec) => {
    if (dec > 0) return n.toFixed(dec);
    return Math.round(n).toLocaleString('en-GB');
  };
  const counters = document.querySelectorAll('[data-count]');
  if ('IntersectionObserver' in window && counters.length) {
    const cio = new IntersectionObserver((entries) => {
      entries.forEach((e) => {
        if (!e.isIntersecting) return;
        const el = e.target;
        cio.unobserve(el);
        const target = parseFloat(el.getAttribute('data-count'));
        const dec = (el.getAttribute('data-count').split('.')[1] || '').length;
        const dur = 1600, t0 = performance.now();
        const tick = (now) => {
          const p = Math.min((now - t0) / dur, 1);
          const eased = 1 - Math.pow(1 - p, 3);
          el.firstChild ? (el.childNodes[0].nodeValue = fmt(target * eased, dec)) : (el.textContent = fmt(target * eased, dec));
          if (p < 1) requestAnimationFrame(tick);
        };
        requestAnimationFrame(tick);
      });
    }, { threshold: 0.5 });
    counters.forEach((c) => cio.observe(c));
  }

  /* Mobile nav */
  const toggle = document.querySelector('.nav-toggle');
  const drawer = document.querySelector('.mobile-drawer');
  if (toggle && drawer) {
    toggle.addEventListener('click', () => {
      const open = drawer.classList.toggle('open');
      toggle.setAttribute('aria-expanded', open);
      document.body.style.overflow = open ? 'hidden' : '';
    });
    drawer.querySelectorAll('a').forEach((a) => a.addEventListener('click', () => {
      drawer.classList.remove('open');
      document.body.style.overflow = '';
    }));
  }

  /* Accordion (SEO long-form) */
  document.querySelectorAll('[data-accordion] .acc-item').forEach((item) => {
    const head = item.querySelector('.acc-head');
    head && head.addEventListener('click', () => {
      const open = item.classList.contains('open');
      // optional single-open: comment out next line for multi-open
      item.parentElement.querySelectorAll('.acc-item.open').forEach((o) => { if (o !== item) o.classList.remove('open'); });
      item.classList.toggle('open', !open);
    });
  });


  /* FAQ toggles (integration pages) */
  document.querySelectorAll('.faq-q').forEach((q) => {
    q.addEventListener('click', () => {
      const item = q.closest('.faq-item');
      if (item) item.classList.toggle('open');
    });
  });

  /* =========================================================
     FORM SUBMISSIONS  (contact.html + get-pricing.html)
     ---------------------------------------------------------
     Submissions are delivered by Web3Forms — a free service that
     emails form entries straight to your inbox. No backend needed.

     ONE-TIME SETUP (≈2 minutes):
       1. Go to https://web3forms.com
       2. Enter  sales@pulsefulfilment.co.uk  and press "Create Access Key".
       3. Web3Forms emails you an Access Key (a UUID like
          "a1b2c3d4-...."). Open this file and paste it below,
          replacing REPLACE_WITH_YOUR_WEB3FORMS_ACCESS_KEY.
       4. The FIRST time a form is submitted, Web3Forms sends a
          confirmation email — click the link once to activate.
     After that, every enquiry lands in the inbox automatically.
     To send somewhere else later, just generate a key for that
     address and swap it here.
  ========================================================= */
  window.PULSE_WEB3FORMS_KEY = 'a6cab6b9-f6ae-487f-9d74-3f334351aa48';

  window.pulseSubmitForm = function (fields) {
    var key = window.PULSE_WEB3FORMS_KEY;
    // Guard: if the key hasn't been set yet, don't fire a doomed request.
    if (!key || /REPLACE_WITH/.test(key)) {
      console.warn('[Pulse] Web3Forms access key not set in assets/site.js — submission was NOT sent. Add your key to start receiving enquiries.');
      return Promise.resolve({ success: false, skipped: true });
    }
    var body = Object.assign({
      access_key: key,
      from_name: 'Pulse Fulfilment website',
      botcheck: false
    }, fields);
    return fetch('https://api.web3forms.com/submit', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
      body: JSON.stringify(body)
    }).then(function (r) { return r.json(); });
  };


  /* =========================================================
     ANALYTICS EVENTS + COOKIE CONSENT
     Events are sent to GA4 via gtag(). In GA4 Admin > Events, mark
     generate_lead, book_call_scheduled, phone_click and email_click
     as key events (conversions) to see them in reports.
  ========================================================= */
  function track(name, params) {
    try { if (typeof window.gtag === 'function') window.gtag('event', name, params || {}); } catch (e) {}
  }
  window.pulseTrack = track;

  // Phone, email, Calendly and CTA clicks (works for links added later too)
  document.addEventListener('click', function (e) {
    var a = e.target.closest && e.target.closest('a[href]');
    if (!a) return;
    var href = a.getAttribute('href') || '';
    var text = (a.textContent || '').trim().slice(0, 80);
    if (href.indexOf('tel:') === 0) track('phone_click', { link_url: href, link_text: text, page_location: location.href });
    else if (href.indexOf('mailto:') === 0) track('email_click', { link_url: href, link_text: text, page_location: location.href });
    else if (href.indexOf('calendly.com') !== -1) track('book_call_click', { link_url: href, link_text: text, page_location: location.href });
    else if (a.classList.contains('btn') && /^\/(contact|get-pricing)(\/|$)/.test(href)) track('cta_click', { link_url: href, link_text: text, page_location: location.href });
  }, true);

  // Form submissions: wrap the Web3Forms helper so every successful send is counted
  if (typeof window.pulseSubmitForm === 'function') {
    var originalSubmit = window.pulseSubmitForm;
    window.pulseSubmitForm = function (fields) {
      var subject = (fields && fields.subject) || '';
      var formName = /pricing/i.test(subject) ? 'get_pricing_form' : 'contact_form';
      return originalSubmit(fields).then(function (res) {
        if (res && res.success) track('generate_lead', { form_name: formName, page_location: location.href });
        return res;
      });
    };
  }

  // Calendly booking completed (Calendly posts a message to the page when a slot is booked)
  window.addEventListener('message', function (e) {
    if (e.data && e.data.event === 'calendly.event_scheduled') track('book_call_scheduled', { page_location: location.href });
  });

  // Cookie consent banner (Google Consent Mode v2). Choice is stored in localStorage.
  function setConsent(choice) {
    try { localStorage.setItem('pulse_consent', choice); } catch (e) {}
    try { if (typeof window.gtag === 'function') window.gtag('consent', 'update', { analytics_storage: choice === 'granted' ? 'granted' : 'denied' }); } catch (e) {}
  }
  function showBanner() {
    if (document.getElementById('cookieBar')) return;
    var bar = document.createElement('div');
    bar.id = 'cookieBar'; bar.className = 'cookie-bar'; bar.setAttribute('role', 'dialog'); bar.setAttribute('aria-label', 'Cookie settings');
    bar.innerHTML = '<p>We use cookies to understand how our site is used. Analytics cookies are only set if you accept. <a href="/privacy#cookies">Privacy &amp; cookie policy</a></p>' +
      '<div class="cookie-actions"><button type="button" class="btn btn-ghost" data-consent="denied">Reject</button><button type="button" class="btn btn-grad" data-consent="granted">Accept</button></div>';
    bar.addEventListener('click', function (e) {
      var b = e.target.closest('[data-consent]'); if (!b) return;
      setConsent(b.getAttribute('data-consent'));
      track('cookie_consent', { choice: b.getAttribute('data-consent') });
      bar.remove();
    });
    document.body.appendChild(bar);
  }
  var stored = null;
  try { stored = localStorage.getItem('pulse_consent'); } catch (e) {}
  if (stored !== 'granted' && stored !== 'denied') showBanner();
  document.addEventListener('click', function (e) {
    var l = e.target.closest && e.target.closest('[data-cookie-settings]');
    if (!l) return;
    e.preventDefault(); showBanner();
    var bar = document.getElementById('cookieBar'); if (bar) bar.scrollIntoView({ block: 'end' });
  });

})();
