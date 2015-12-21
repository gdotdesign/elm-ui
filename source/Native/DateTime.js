Elm.Native.DateTime = {};
Elm.Native.DateTime.make = function(elm) {
  elm.Native = elm.Native || {};
  elm.Native.DateTime = elm.Native.DateTime || {};
  if (elm.Native.DateTime.values) { return elm.Native.DateTime.values; }

  /* Function to return the current day. */
  function now(){
    return new Date()
  }

  /* Create a date from the given arguments. */
  function create(year, month, day){
    return new Date(year, month - 1 , day);
  }

  /* Get the days in the month of the given date. */
  function daysInMonth(date) {
    return new Date(date.getYear(),date.getMonth() + 1,0).getDate();
  }

  /* Get the month of the given date. */
  function month(date){
    return date.getMonth() + 1;
  }

  /* Interface. */
  return elm.Native.DateTime.values = {
    daysInMonth: daysInMonth,
    create: F3(create),
    month: month,
    now: now
  };
};
