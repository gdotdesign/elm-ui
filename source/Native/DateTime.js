var _gdotdesign$elm_ui$Native_DateTime = function() {
  /* Function to return the current day. */
  function now(){
    return new Date()
  }

  /* Create a date from the given arguments. */
  function create(year, month, day){
    return new Date(year, month - 1 , day)
  }

  /* Get the days in the month of the given date. */
  function daysInMonth(date) {
    return new Date(date.getYear(),date.getMonth() + 1,0).getDate()
  }

  /* Get the month of the given date. */
  function month(date){
    return date.getMonth() + 1
  }

  function setInterval_(interval, task)
  {
    return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
    {
      var id = setInterval(function() {
        _elm_lang$core$Native_Scheduler.rawSpawn(task);
      }, interval);

      return function() { clearInterval(id); };
    });
  }

  /* Interface. */
  return {
    setInterval: F2(setInterval_),
    daysInMonth: daysInMonth,
    create: F3(create),
    month: month,
    now: now
  }
}()
