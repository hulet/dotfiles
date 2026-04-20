javascript:(function(){
  /* Copy email addresses from the page to the clipboard */
  /* Create a new browser bookmark with name `email` and this as the URL */
  const pageText = document.body.innerText;
  const emailRegex = /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/g;
  const emails = pageText.match(emailRegex);

  if (emails && emails.length > 0) {
    const uniqueEmails = [...new Set(emails)];
    const emailString = uniqueEmails.join('\n');
    
    /* Create the floating button */
    const btn = document.createElement('button');
    btn.innerHTML = `Copy ${uniqueEmails.length} Email(s) to Clipboard`;
    btn.style = "position:fixed;top:20px;left:50%;transform:translateX(-50%);z-index:999999;padding:12px 24px;background:#2563eb;color:white;border:none;border-radius:8px;cursor:pointer;font-family:sans-serif;box-shadow:0 10px 15px -3px rgba(0,0,0,0.1);font-weight:600;transition:all 0.3s ease;opacity:1;";
    
    btn.onclick = function() {
      navigator.clipboard.writeText(emailString).then(() => {
        /* Success State */
        btn.innerHTML = `✅ ${uniqueEmails.length} Email(s) Copied!`;
        btn.style.background = "#059669";
        btn.style.pointerEvents = "none"; /* Prevent double clicks */
        
        /* Fade out and remove after 5 seconds */
        setTimeout(() => {
          btn.style.opacity = "0";
          setTimeout(() => {
            if(btn.parentNode) document.body.removeChild(btn);
          }, 300);
        }, 5000);
        
      }).catch(err => {
        btn.innerHTML = "Error Copying!";
        btn.style.background = "#dc2626";
      });
    };

    /* Instant removal if you click it after success (manual clear) */
    btn.oncontextmenu = (e) => { e.preventDefault(); document.body.removeChild(btn); };

    document.body.appendChild(btn);
  } else {
    /* Optional: Still using a small alert here only if nothing is found */
    alert('No emails found on this page.');
  }
})();
