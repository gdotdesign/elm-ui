Elm.Native.DateTime = {};
Elm.Native.DateTime.make = function(elm) {
  elm.Native = elm.Native || {};
  elm.Native.DateTime = elm.Native.DateTime || {};
  if (elm.Native.DateTime.values) {
    return elm.Native.DateTime.values;
  }

  function now(){
    return new Date()
  }

  function create(year, month, day){
    return new Date(year, month - 1 , day);
  }

  function daysInMonth(date) {
    return new Date(date.getYear(),date.getMonth() + 1,0).getDate();
  }

  function month(date){
    return date.getMonth() + 1;
  }

  return Elm.Native.DateTime.values = {
    now: now,
    create: F3(create),
    daysInMonth: daysInMonth,
    month: month
  };
};
