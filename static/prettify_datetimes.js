document.addEventListener("DOMContentLoaded", function(event) {
  // Function to process and format a <time> element
  const processTimeElement = (element) => {
    if (
      element.nodeType === 1 &&
      element.tagName === 'TIME' &&
      element.hasAttribute('datetime') &&
      !element.hasAttribute('x-transformed')
    ) {
      const datetimeStr = element.getAttribute('datetime');
      const date = new Date(datetimeStr);
      const now = new Date();
      const fullOptions = { dateStyle: 'full', timeStyle: 'long' };

      // Use Intl.RelativeTimeFormat if available, otherwise fall back to toLocaleDateString
      if (typeof Intl.RelativeTimeFormat !== 'undefined') {
        // Undefined uses users local default
        const rtf = new Intl.RelativeTimeFormat(undefined, { numeric: 'auto' });

        const seconds = Math.round((date - now) / 1000);
        const minutes = Math.round(seconds / 60);
        const hours = Math.round(minutes / 60);
        const days = Math.round(hours / 24);
        const months = Math.round(days / 30);
        const years = Math.round(days / 365);

        // Determine the most appropriate unit to display
        let formattedDate;
        if (Math.abs(years) > 0) {
          formattedDate = rtf.format(years, 'year');
        } else if (Math.abs(months) > 0) {
          formattedDate = rtf.format(months, 'month');
        } else if (Math.abs(days) > 0) {
          formattedDate = rtf.format(days, 'day');
        } else if (Math.abs(hours) > 0) {
          formattedDate = rtf.format(hours, 'hour');
        } else if (Math.abs(minutes) > 0) {
          formattedDate = rtf.format(minutes, 'minute');
        } else {
          formattedDate = rtf.format(seconds, 'second');
        }

        element.textContent = formattedDate;
      } else {
        // Fallback to local date string
        element.textContent = date.toLocaleString(undefined, fullOptions);
      }

      // Set the full, localized date string as the title for detailed view
      // Undefined uses users local default
      element.title = date.toLocaleString(undefined, fullOptions); 

      // Set attribute so it is not transformed again
      element.setAttribute('x-transformed', '');
    }
  };

  // Process any new <time> elements added to the page
  const config = { attributes: false, childList: true, subtree: true };
  const observer = new MutationObserver(function (mutationsList, observer) {
    for (const mutation of mutationsList) {
      if (mutation.type === 'childList') {
        mutation.addedNodes.forEach(node => {
          processTimeElement(node);
        });
      }
    }
  });
  observer.observe(document.body, config);

  // Process any time elements added by htmx
  up.on('up:fragment:inserted', function(_event) {
    document.querySelectorAll('time').forEach(processTimeElement);
  });

  // Process all existing <time> elements on the page
  document.querySelectorAll('time').forEach(processTimeElement);
});
