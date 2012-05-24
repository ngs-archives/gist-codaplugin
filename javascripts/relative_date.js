/**
 * Simple relative date.
 *
 * Returns a string like "4 days ago". Prefers to return values >= 2. For example, it would
 * return "26 hours ago" instead of "1 day ago", but would return "2 days ago" instead of
 * "49 hours ago".
 *
 * Copyright (c) 2008 Erik Hanson http://www.eahanson.com/
 * Licensed under the MIT License http://www.opensource.org/licenses/mit-license.php
 */
function relativeDate(olderDate, newerDate) {
  if (typeof olderDate == "string") olderDate = new Date(olderDate);
  if (typeof newerDate == "string") newerDate = new Date(newerDate);

  var milliseconds = newerDate - olderDate;

  var conversions = [
    ["years", 31518720000],
    ["months", 2626560000 /* assumes there are 30.4 days in a month */],
    ["days", 86400000],
    ["hours", 3600000],
    ["minutes", 60000],
    ["seconds", 1000]
  ];

  for (var i = 0; i < conversions.length; i++) {
    var result = Math.floor(milliseconds / conversions[i][1]);
    if (result >= 2) {
      return result + " " + conversions[i][0] + " ago";
    }
  }

  return "1 second ago";
}

/** @see http://www.eahanson.com/2008/12/04/relative-dates-in-javascript/ */