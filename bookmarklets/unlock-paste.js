javascript:(function(){
  /* Allow paste in all inputs */
  /* Create a new browser bookmark with name `cp` and this as the URL */
  const events = ['paste', 'copy', 'cut', 'contextmenu', 'dragstart', 'drop', 'keydown', 'keyup', 'keypress'];
  const allowEvent = (e) => {
    e.stopImmediatePropagation();
    return true;
  };

  /* Target all elements and the document itself */
  const allElements = document.querySelectorAll('*');
  
  allElements.forEach(el => {
    events.forEach(eventType => {
      /* Remove inline handlers */
      el['on' + eventType] = null;
      /* Bypass listeners by capturing them early and stopping propagation */
      el.addEventListener(eventType, allowEvent, true);
    });
    
    /* Force enable user-select in case they blocked highlighting */
    el.style.setProperty('user-select', 'text', 'important');
    el.style.setProperty('-webkit-user-select', 'text', 'important');
  });

  /* Special handling for the document/body */
  events.forEach(eventType => {
    document.addEventListener(eventType, allowEvent, true);
  });

  console.log('Paste restrictions bypassed.');
  alert('Paste restrictions disabled on this page!');
})();
