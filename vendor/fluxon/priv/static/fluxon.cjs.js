var __create = Object.create;
var __defProp = Object.defineProperty;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __getProtoOf = Object.getPrototypeOf;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __commonJS = (cb, mod) => function __require() {
  return mod || (0, cb[__getOwnPropNames(cb)[0]])((mod = { exports: {} }).exports, mod), mod.exports;
};
var __export = (target, all) => {
  for (var name in all)
    __defProp(target, name, { get: all[name], enumerable: true });
};
var __copyProps = (to, from, except, desc) => {
  if (from && typeof from === "object" || typeof from === "function") {
    for (let key of __getOwnPropNames(from))
      if (!__hasOwnProp.call(to, key) && key !== except)
        __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
  }
  return to;
};
var __toESM = (mod, isNodeMode, target) => (target = mod != null ? __create(__getProtoOf(mod)) : {}, __copyProps(
  // If the importer is in node compatibility mode or this is not an ESM
  // file that has been converted to a CommonJS file using a Babel-
  // compatible transform (i.e. "__esModule" has not been set), then set
  // "default" to the CommonJS "module.exports" for node compatibility.
  isNodeMode || !mod || !mod.__esModule ? __defProp(target, "default", { value: mod, enumerable: true }) : target,
  mod
));
var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);

// node_modules/.pnpm/dayjs@1.11.13/node_modules/dayjs/dayjs.min.js
var require_dayjs_min = __commonJS({
  "node_modules/.pnpm/dayjs@1.11.13/node_modules/dayjs/dayjs.min.js"(exports, module2) {
    !function(t, e) {
      "object" == typeof exports && "undefined" != typeof module2 ? module2.exports = e() : "function" == typeof define && define.amd ? define(e) : (t = "undefined" != typeof globalThis ? globalThis : t || self).dayjs = e();
    }(exports, function() {
      "use strict";
      var t = 1e3, e = 6e4, n = 36e5, r = "millisecond", i = "second", s = "minute", u = "hour", a = "day", o = "week", c = "month", f = "quarter", h = "year", d = "date", l = "Invalid Date", $ = /^(\d{4})[-/]?(\d{1,2})?[-/]?(\d{0,2})[Tt\s]*(\d{1,2})?:?(\d{1,2})?:?(\d{1,2})?[.:]?(\d+)?$/, y = /\[([^\]]+)]|Y{1,4}|M{1,4}|D{1,2}|d{1,4}|H{1,2}|h{1,2}|a|A|m{1,2}|s{1,2}|Z{1,2}|SSS/g, M = { name: "en", weekdays: "Sunday_Monday_Tuesday_Wednesday_Thursday_Friday_Saturday".split("_"), months: "January_February_March_April_May_June_July_August_September_October_November_December".split("_"), ordinal: function(t2) {
        var e2 = ["th", "st", "nd", "rd"], n2 = t2 % 100;
        return "[" + t2 + (e2[(n2 - 20) % 10] || e2[n2] || e2[0]) + "]";
      } }, m = function(t2, e2, n2) {
        var r2 = String(t2);
        return !r2 || r2.length >= e2 ? t2 : "" + Array(e2 + 1 - r2.length).join(n2) + t2;
      }, v = { s: m, z: function(t2) {
        var e2 = -t2.utcOffset(), n2 = Math.abs(e2), r2 = Math.floor(n2 / 60), i2 = n2 % 60;
        return (e2 <= 0 ? "+" : "-") + m(r2, 2, "0") + ":" + m(i2, 2, "0");
      }, m: function t2(e2, n2) {
        if (e2.date() < n2.date()) return -t2(n2, e2);
        var r2 = 12 * (n2.year() - e2.year()) + (n2.month() - e2.month()), i2 = e2.clone().add(r2, c), s2 = n2 - i2 < 0, u2 = e2.clone().add(r2 + (s2 ? -1 : 1), c);
        return +(-(r2 + (n2 - i2) / (s2 ? i2 - u2 : u2 - i2)) || 0);
      }, a: function(t2) {
        return t2 < 0 ? Math.ceil(t2) || 0 : Math.floor(t2);
      }, p: function(t2) {
        return { M: c, y: h, w: o, d: a, D: d, h: u, m: s, s: i, ms: r, Q: f }[t2] || String(t2 || "").toLowerCase().replace(/s$/, "");
      }, u: function(t2) {
        return void 0 === t2;
      } }, g = "en", D = {};
      D[g] = M;
      var p = "$isDayjsObject", S = function(t2) {
        return t2 instanceof _ || !(!t2 || !t2[p]);
      }, w = function t2(e2, n2, r2) {
        var i2;
        if (!e2) return g;
        if ("string" == typeof e2) {
          var s2 = e2.toLowerCase();
          D[s2] && (i2 = s2), n2 && (D[s2] = n2, i2 = s2);
          var u2 = e2.split("-");
          if (!i2 && u2.length > 1) return t2(u2[0]);
        } else {
          var a2 = e2.name;
          D[a2] = e2, i2 = a2;
        }
        return !r2 && i2 && (g = i2), i2 || !r2 && g;
      }, O = function(t2, e2) {
        if (S(t2)) return t2.clone();
        var n2 = "object" == typeof e2 ? e2 : {};
        return n2.date = t2, n2.args = arguments, new _(n2);
      }, b = v;
      b.l = w, b.i = S, b.w = function(t2, e2) {
        return O(t2, { locale: e2.$L, utc: e2.$u, x: e2.$x, $offset: e2.$offset });
      };
      var _ = function() {
        function M2(t2) {
          this.$L = w(t2.locale, null, true), this.parse(t2), this.$x = this.$x || t2.x || {}, this[p] = true;
        }
        var m2 = M2.prototype;
        return m2.parse = function(t2) {
          this.$d = function(t3) {
            var e2 = t3.date, n2 = t3.utc;
            if (null === e2) return /* @__PURE__ */ new Date(NaN);
            if (b.u(e2)) return /* @__PURE__ */ new Date();
            if (e2 instanceof Date) return new Date(e2);
            if ("string" == typeof e2 && !/Z$/i.test(e2)) {
              var r2 = e2.match($);
              if (r2) {
                var i2 = r2[2] - 1 || 0, s2 = (r2[7] || "0").substring(0, 3);
                return n2 ? new Date(Date.UTC(r2[1], i2, r2[3] || 1, r2[4] || 0, r2[5] || 0, r2[6] || 0, s2)) : new Date(r2[1], i2, r2[3] || 1, r2[4] || 0, r2[5] || 0, r2[6] || 0, s2);
              }
            }
            return new Date(e2);
          }(t2), this.init();
        }, m2.init = function() {
          var t2 = this.$d;
          this.$y = t2.getFullYear(), this.$M = t2.getMonth(), this.$D = t2.getDate(), this.$W = t2.getDay(), this.$H = t2.getHours(), this.$m = t2.getMinutes(), this.$s = t2.getSeconds(), this.$ms = t2.getMilliseconds();
        }, m2.$utils = function() {
          return b;
        }, m2.isValid = function() {
          return !(this.$d.toString() === l);
        }, m2.isSame = function(t2, e2) {
          var n2 = O(t2);
          return this.startOf(e2) <= n2 && n2 <= this.endOf(e2);
        }, m2.isAfter = function(t2, e2) {
          return O(t2) < this.startOf(e2);
        }, m2.isBefore = function(t2, e2) {
          return this.endOf(e2) < O(t2);
        }, m2.$g = function(t2, e2, n2) {
          return b.u(t2) ? this[e2] : this.set(n2, t2);
        }, m2.unix = function() {
          return Math.floor(this.valueOf() / 1e3);
        }, m2.valueOf = function() {
          return this.$d.getTime();
        }, m2.startOf = function(t2, e2) {
          var n2 = this, r2 = !!b.u(e2) || e2, f2 = b.p(t2), l2 = function(t3, e3) {
            var i2 = b.w(n2.$u ? Date.UTC(n2.$y, e3, t3) : new Date(n2.$y, e3, t3), n2);
            return r2 ? i2 : i2.endOf(a);
          }, $2 = function(t3, e3) {
            return b.w(n2.toDate()[t3].apply(n2.toDate("s"), (r2 ? [0, 0, 0, 0] : [23, 59, 59, 999]).slice(e3)), n2);
          }, y2 = this.$W, M3 = this.$M, m3 = this.$D, v2 = "set" + (this.$u ? "UTC" : "");
          switch (f2) {
            case h:
              return r2 ? l2(1, 0) : l2(31, 11);
            case c:
              return r2 ? l2(1, M3) : l2(0, M3 + 1);
            case o:
              var g2 = this.$locale().weekStart || 0, D2 = (y2 < g2 ? y2 + 7 : y2) - g2;
              return l2(r2 ? m3 - D2 : m3 + (6 - D2), M3);
            case a:
            case d:
              return $2(v2 + "Hours", 0);
            case u:
              return $2(v2 + "Minutes", 1);
            case s:
              return $2(v2 + "Seconds", 2);
            case i:
              return $2(v2 + "Milliseconds", 3);
            default:
              return this.clone();
          }
        }, m2.endOf = function(t2) {
          return this.startOf(t2, false);
        }, m2.$set = function(t2, e2) {
          var n2, o2 = b.p(t2), f2 = "set" + (this.$u ? "UTC" : ""), l2 = (n2 = {}, n2[a] = f2 + "Date", n2[d] = f2 + "Date", n2[c] = f2 + "Month", n2[h] = f2 + "FullYear", n2[u] = f2 + "Hours", n2[s] = f2 + "Minutes", n2[i] = f2 + "Seconds", n2[r] = f2 + "Milliseconds", n2)[o2], $2 = o2 === a ? this.$D + (e2 - this.$W) : e2;
          if (o2 === c || o2 === h) {
            var y2 = this.clone().set(d, 1);
            y2.$d[l2]($2), y2.init(), this.$d = y2.set(d, Math.min(this.$D, y2.daysInMonth())).$d;
          } else l2 && this.$d[l2]($2);
          return this.init(), this;
        }, m2.set = function(t2, e2) {
          return this.clone().$set(t2, e2);
        }, m2.get = function(t2) {
          return this[b.p(t2)]();
        }, m2.add = function(r2, f2) {
          var d2, l2 = this;
          r2 = Number(r2);
          var $2 = b.p(f2), y2 = function(t2) {
            var e2 = O(l2);
            return b.w(e2.date(e2.date() + Math.round(t2 * r2)), l2);
          };
          if ($2 === c) return this.set(c, this.$M + r2);
          if ($2 === h) return this.set(h, this.$y + r2);
          if ($2 === a) return y2(1);
          if ($2 === o) return y2(7);
          var M3 = (d2 = {}, d2[s] = e, d2[u] = n, d2[i] = t, d2)[$2] || 1, m3 = this.$d.getTime() + r2 * M3;
          return b.w(m3, this);
        }, m2.subtract = function(t2, e2) {
          return this.add(-1 * t2, e2);
        }, m2.format = function(t2) {
          var e2 = this, n2 = this.$locale();
          if (!this.isValid()) return n2.invalidDate || l;
          var r2 = t2 || "YYYY-MM-DDTHH:mm:ssZ", i2 = b.z(this), s2 = this.$H, u2 = this.$m, a2 = this.$M, o2 = n2.weekdays, c2 = n2.months, f2 = n2.meridiem, h2 = function(t3, n3, i3, s3) {
            return t3 && (t3[n3] || t3(e2, r2)) || i3[n3].slice(0, s3);
          }, d2 = function(t3) {
            return b.s(s2 % 12 || 12, t3, "0");
          }, $2 = f2 || function(t3, e3, n3) {
            var r3 = t3 < 12 ? "AM" : "PM";
            return n3 ? r3.toLowerCase() : r3;
          };
          return r2.replace(y, function(t3, r3) {
            return r3 || function(t4) {
              switch (t4) {
                case "YY":
                  return String(e2.$y).slice(-2);
                case "YYYY":
                  return b.s(e2.$y, 4, "0");
                case "M":
                  return a2 + 1;
                case "MM":
                  return b.s(a2 + 1, 2, "0");
                case "MMM":
                  return h2(n2.monthsShort, a2, c2, 3);
                case "MMMM":
                  return h2(c2, a2);
                case "D":
                  return e2.$D;
                case "DD":
                  return b.s(e2.$D, 2, "0");
                case "d":
                  return String(e2.$W);
                case "dd":
                  return h2(n2.weekdaysMin, e2.$W, o2, 2);
                case "ddd":
                  return h2(n2.weekdaysShort, e2.$W, o2, 3);
                case "dddd":
                  return o2[e2.$W];
                case "H":
                  return String(s2);
                case "HH":
                  return b.s(s2, 2, "0");
                case "h":
                  return d2(1);
                case "hh":
                  return d2(2);
                case "a":
                  return $2(s2, u2, true);
                case "A":
                  return $2(s2, u2, false);
                case "m":
                  return String(u2);
                case "mm":
                  return b.s(u2, 2, "0");
                case "s":
                  return String(e2.$s);
                case "ss":
                  return b.s(e2.$s, 2, "0");
                case "SSS":
                  return b.s(e2.$ms, 3, "0");
                case "Z":
                  return i2;
              }
              return null;
            }(t3) || i2.replace(":", "");
          });
        }, m2.utcOffset = function() {
          return 15 * -Math.round(this.$d.getTimezoneOffset() / 15);
        }, m2.diff = function(r2, d2, l2) {
          var $2, y2 = this, M3 = b.p(d2), m3 = O(r2), v2 = (m3.utcOffset() - this.utcOffset()) * e, g2 = this - m3, D2 = function() {
            return b.m(y2, m3);
          };
          switch (M3) {
            case h:
              $2 = D2() / 12;
              break;
            case c:
              $2 = D2();
              break;
            case f:
              $2 = D2() / 3;
              break;
            case o:
              $2 = (g2 - v2) / 6048e5;
              break;
            case a:
              $2 = (g2 - v2) / 864e5;
              break;
            case u:
              $2 = g2 / n;
              break;
            case s:
              $2 = g2 / e;
              break;
            case i:
              $2 = g2 / t;
              break;
            default:
              $2 = g2;
          }
          return l2 ? $2 : b.a($2);
        }, m2.daysInMonth = function() {
          return this.endOf(c).$D;
        }, m2.$locale = function() {
          return D[this.$L];
        }, m2.locale = function(t2, e2) {
          if (!t2) return this.$L;
          var n2 = this.clone(), r2 = w(t2, e2, true);
          return r2 && (n2.$L = r2), n2;
        }, m2.clone = function() {
          return b.w(this.$d, this);
        }, m2.toDate = function() {
          return new Date(this.valueOf());
        }, m2.toJSON = function() {
          return this.isValid() ? this.toISOString() : null;
        }, m2.toISOString = function() {
          return this.$d.toISOString();
        }, m2.toString = function() {
          return this.$d.toUTCString();
        }, M2;
      }(), k = _.prototype;
      return O.prototype = k, [["$ms", r], ["$s", i], ["$m", s], ["$H", u], ["$W", a], ["$M", c], ["$y", h], ["$D", d]].forEach(function(t2) {
        k[t2[1]] = function(e2) {
          return this.$g(e2, t2[0], t2[1]);
        };
      }), O.extend = function(t2, e2) {
        return t2.$i || (t2(e2, _, O), t2.$i = true), O;
      }, O.locale = w, O.isDayjs = S, O.unix = function(t2) {
        return O(1e3 * t2);
      }, O.en = D[g], O.Ls = D, O.p = {}, O;
    });
  }
});

// node_modules/.pnpm/dayjs@1.11.13/node_modules/dayjs/plugin/utc.js
var require_utc = __commonJS({
  "node_modules/.pnpm/dayjs@1.11.13/node_modules/dayjs/plugin/utc.js"(exports, module2) {
    !function(t, i) {
      "object" == typeof exports && "undefined" != typeof module2 ? module2.exports = i() : "function" == typeof define && define.amd ? define(i) : (t = "undefined" != typeof globalThis ? globalThis : t || self).dayjs_plugin_utc = i();
    }(exports, function() {
      "use strict";
      var t = "minute", i = /[+-]\d\d(?::?\d\d)?/g, e = /([+-]|\d\d)/g;
      return function(s, f, n) {
        var u = f.prototype;
        n.utc = function(t2) {
          var i2 = { date: t2, utc: true, args: arguments };
          return new f(i2);
        }, u.utc = function(i2) {
          var e2 = n(this.toDate(), { locale: this.$L, utc: true });
          return i2 ? e2.add(this.utcOffset(), t) : e2;
        }, u.local = function() {
          return n(this.toDate(), { locale: this.$L, utc: false });
        };
        var o = u.parse;
        u.parse = function(t2) {
          t2.utc && (this.$u = true), this.$utils().u(t2.$offset) || (this.$offset = t2.$offset), o.call(this, t2);
        };
        var r = u.init;
        u.init = function() {
          if (this.$u) {
            var t2 = this.$d;
            this.$y = t2.getUTCFullYear(), this.$M = t2.getUTCMonth(), this.$D = t2.getUTCDate(), this.$W = t2.getUTCDay(), this.$H = t2.getUTCHours(), this.$m = t2.getUTCMinutes(), this.$s = t2.getUTCSeconds(), this.$ms = t2.getUTCMilliseconds();
          } else r.call(this);
        };
        var a = u.utcOffset;
        u.utcOffset = function(s2, f2) {
          var n2 = this.$utils().u;
          if (n2(s2)) return this.$u ? 0 : n2(this.$offset) ? a.call(this) : this.$offset;
          if ("string" == typeof s2 && (s2 = function(t2) {
            void 0 === t2 && (t2 = "");
            var s3 = t2.match(i);
            if (!s3) return null;
            var f3 = ("" + s3[0]).match(e) || ["-", 0, 0], n3 = f3[0], u3 = 60 * +f3[1] + +f3[2];
            return 0 === u3 ? 0 : "+" === n3 ? u3 : -u3;
          }(s2), null === s2)) return this;
          var u2 = Math.abs(s2) <= 16 ? 60 * s2 : s2, o2 = this;
          if (f2) return o2.$offset = u2, o2.$u = 0 === s2, o2;
          if (0 !== s2) {
            var r2 = this.$u ? this.toDate().getTimezoneOffset() : -1 * this.utcOffset();
            (o2 = this.local().add(u2 + r2, t)).$offset = u2, o2.$x.$localOffset = r2;
          } else o2 = this.utc();
          return o2;
        };
        var h = u.format;
        u.format = function(t2) {
          var i2 = t2 || (this.$u ? "YYYY-MM-DDTHH:mm:ss[Z]" : "");
          return h.call(this, i2);
        }, u.valueOf = function() {
          var t2 = this.$utils().u(this.$offset) ? 0 : this.$offset + (this.$x.$localOffset || this.$d.getTimezoneOffset());
          return this.$d.valueOf() - 6e4 * t2;
        }, u.isUTC = function() {
          return !!this.$u;
        }, u.toISOString = function() {
          return this.toDate().toISOString();
        }, u.toString = function() {
          return this.toDate().toUTCString();
        };
        var l = u.toDate;
        u.toDate = function(t2) {
          return "s" === t2 && this.$offset ? n(this.format("YYYY-MM-DD HH:mm:ss:SSS")).toDate() : l.call(this);
        };
        var c = u.diff;
        u.diff = function(t2, i2, e2) {
          if (t2 && this.$u === t2.$u) return c.call(this, t2, i2, e2);
          var s2 = this.local(), f2 = n(t2).local();
          return c.call(s2, f2, i2, e2);
        };
      };
    });
  }
});

// node_modules/.pnpm/dayjs@1.11.13/node_modules/dayjs/plugin/timezone.js
var require_timezone = __commonJS({
  "node_modules/.pnpm/dayjs@1.11.13/node_modules/dayjs/plugin/timezone.js"(exports, module2) {
    !function(t, e) {
      "object" == typeof exports && "undefined" != typeof module2 ? module2.exports = e() : "function" == typeof define && define.amd ? define(e) : (t = "undefined" != typeof globalThis ? globalThis : t || self).dayjs_plugin_timezone = e();
    }(exports, function() {
      "use strict";
      var t = { year: 0, month: 1, day: 2, hour: 3, minute: 4, second: 5 }, e = {};
      return function(n, i, o) {
        var r, a = function(t2, n2, i2) {
          void 0 === i2 && (i2 = {});
          var o2 = new Date(t2), r2 = function(t3, n3) {
            void 0 === n3 && (n3 = {});
            var i3 = n3.timeZoneName || "short", o3 = t3 + "|" + i3, r3 = e[o3];
            return r3 || (r3 = new Intl.DateTimeFormat("en-US", { hour12: false, timeZone: t3, year: "numeric", month: "2-digit", day: "2-digit", hour: "2-digit", minute: "2-digit", second: "2-digit", timeZoneName: i3 }), e[o3] = r3), r3;
          }(n2, i2);
          return r2.formatToParts(o2);
        }, u = function(e2, n2) {
          for (var i2 = a(e2, n2), r2 = [], u2 = 0; u2 < i2.length; u2 += 1) {
            var f2 = i2[u2], s2 = f2.type, m = f2.value, c = t[s2];
            c >= 0 && (r2[c] = parseInt(m, 10));
          }
          var d = r2[3], l = 24 === d ? 0 : d, h = r2[0] + "-" + r2[1] + "-" + r2[2] + " " + l + ":" + r2[4] + ":" + r2[5] + ":000", v = +e2;
          return (o.utc(h).valueOf() - (v -= v % 1e3)) / 6e4;
        }, f = i.prototype;
        f.tz = function(t2, e2) {
          void 0 === t2 && (t2 = r);
          var n2, i2 = this.utcOffset(), a2 = this.toDate(), u2 = a2.toLocaleString("en-US", { timeZone: t2 }), f2 = Math.round((a2 - new Date(u2)) / 1e3 / 60), s2 = 15 * -Math.round(a2.getTimezoneOffset() / 15) - f2;
          if (!Number(s2)) n2 = this.utcOffset(0, e2);
          else if (n2 = o(u2, { locale: this.$L }).$set("millisecond", this.$ms).utcOffset(s2, true), e2) {
            var m = n2.utcOffset();
            n2 = n2.add(i2 - m, "minute");
          }
          return n2.$x.$timezone = t2, n2;
        }, f.offsetName = function(t2) {
          var e2 = this.$x.$timezone || o.tz.guess(), n2 = a(this.valueOf(), e2, { timeZoneName: t2 }).find(function(t3) {
            return "timezonename" === t3.type.toLowerCase();
          });
          return n2 && n2.value;
        };
        var s = f.startOf;
        f.startOf = function(t2, e2) {
          if (!this.$x || !this.$x.$timezone) return s.call(this, t2, e2);
          var n2 = o(this.format("YYYY-MM-DD HH:mm:ss:SSS"), { locale: this.$L });
          return s.call(n2, t2, e2).tz(this.$x.$timezone, true);
        }, o.tz = function(t2, e2, n2) {
          var i2 = n2 && e2, a2 = n2 || e2 || r, f2 = u(+o(), a2);
          if ("string" != typeof t2) return o(t2).tz(a2);
          var s2 = function(t3, e3, n3) {
            var i3 = t3 - 60 * e3 * 1e3, o2 = u(i3, n3);
            if (e3 === o2) return [i3, e3];
            var r2 = u(i3 -= 60 * (o2 - e3) * 1e3, n3);
            return o2 === r2 ? [i3, o2] : [t3 - 60 * Math.min(o2, r2) * 1e3, Math.max(o2, r2)];
          }(o.utc(t2, i2).valueOf(), f2, a2), m = s2[0], c = s2[1], d = o(m).utcOffset(c);
          return d.$x.$timezone = a2, d;
        }, o.tz.guess = function() {
          return Intl.DateTimeFormat().resolvedOptions().timeZone;
        }, o.tz.setDefault = function(t2) {
          r = t2;
        };
      };
    });
  }
});

// node_modules/.pnpm/dayjs@1.11.13/node_modules/dayjs/plugin/isoWeek.js
var require_isoWeek = __commonJS({
  "node_modules/.pnpm/dayjs@1.11.13/node_modules/dayjs/plugin/isoWeek.js"(exports, module2) {
    !function(e, t) {
      "object" == typeof exports && "undefined" != typeof module2 ? module2.exports = t() : "function" == typeof define && define.amd ? define(t) : (e = "undefined" != typeof globalThis ? globalThis : e || self).dayjs_plugin_isoWeek = t();
    }(exports, function() {
      "use strict";
      var e = "day";
      return function(t, i, s) {
        var a = function(t2) {
          return t2.add(4 - t2.isoWeekday(), e);
        }, d = i.prototype;
        d.isoWeekYear = function() {
          return a(this).year();
        }, d.isoWeek = function(t2) {
          if (!this.$utils().u(t2)) return this.add(7 * (t2 - this.isoWeek()), e);
          var i2, d2, n2, o, r = a(this), u = (i2 = this.isoWeekYear(), d2 = this.$u, n2 = (d2 ? s.utc : s)().year(i2).startOf("year"), o = 4 - n2.isoWeekday(), n2.isoWeekday() > 4 && (o += 7), n2.add(o, e));
          return r.diff(u, "week") + 1;
        }, d.isoWeekday = function(e2) {
          return this.$utils().u(e2) ? this.day() || 7 : this.day(this.day() % 7 ? e2 : e2 - 7);
        };
        var n = d.startOf;
        d.startOf = function(e2, t2) {
          var i2 = this.$utils(), s2 = !!i2.u(t2) || t2;
          return "isoweek" === i2.p(e2) ? s2 ? this.date(this.date() - (this.isoWeekday() - 1)).startOf("day") : this.date(this.date() - 1 - (this.isoWeekday() - 1) + 7).endOf("day") : n.bind(this)(e2, t2);
        };
      };
    });
  }
});

// js/index.js
var js_exports = {};
__export(js_exports, {
  DOM: () => DOM,
  Hooks: () => hooks_default
});
module.exports = __toCommonJS(js_exports);

// js/components/animator.js
var Animator = class {
  constructor(_rootElement) {
    this.animationAbortControllers = /* @__PURE__ */ new Map();
  }
  parseConfig(element) {
    return {
      base: element.dataset["animation"]?.split(" ").filter(Boolean) || [],
      enter: element.dataset["animationEnter"]?.split(" ").filter(Boolean) || [],
      leave: element.dataset["animationLeave"]?.split(" ").filter(Boolean) || []
    };
  }
  async animateEnter(element) {
    return this.animate(element, "enter");
  }
  async animateLeave(element) {
    return this.animate(element, "leave");
  }
  animate(element, type) {
    const config = this.parseConfig(element);
    if (config.base.length === 0 && config.enter.length === 0) {
      return Promise.resolve(true);
    }
    if (this.animationAbortControllers.has(element)) {
      this.animationAbortControllers.get(element).abort();
      this.animationAbortControllers.delete(element);
    }
    const abortController = new AbortController();
    this.animationAbortControllers.set(element, abortController);
    const signal = abortController.signal;
    return new Promise((resolve) => {
      element.classList.remove(...config.base, ...config.enter, ...config.leave);
      const handleAnimationEnd = (event2) => {
        if (event2.target === element) {
          cleanup();
          if (type === "enter") {
            element.classList.remove(...config.base, ...config.enter);
          }
          resolve(true);
        }
      };
      const cleanup = () => {
        element.removeEventListener("transitionend", handleAnimationEnd);
        element.removeEventListener("animationend", handleAnimationEnd);
        signal.removeEventListener("abort", handleAbort);
        clearTimeout(fallbackTimer);
        this.animationAbortControllers.delete(element);
      };
      const handleAbort = () => {
        cleanup();
        resolve(false);
      };
      element.addEventListener("transitionend", handleAnimationEnd);
      element.addEventListener("animationend", handleAnimationEnd);
      signal.addEventListener("abort", handleAbort);
      if (type === "enter") {
        element.classList.add(...config.leave);
        void element.offsetWidth;
      }
      requestAnimationFrame(() => {
        if (!signal.aborted) {
          element.classList.remove(...config.leave);
          element.classList.add(...config.base, ...type === "enter" ? config.enter : config.leave);
        }
      });
      const fallbackTimer = setTimeout(() => {
        cleanup();
        if (type === "enter") {
          element.classList.remove(...config.base, ...config.enter);
        }
        resolve(true);
      }, 1e3);
    });
  }
};

// js/components/config.js
var Config = class {
  #config;
  constructor(element, definition) {
    this.#config = this.#parseConfig(element, definition);
    this.#setupGetters();
    if (definition.computed) {
      this.#setupComputed(definition.computed);
    }
  }
  // Extracts configuration values from element data attributes according
  // to the provided definition schema.
  #parseConfig(element, definition) {
    const { computed, ...configDefinition } = definition;
    return Object.entries(configDefinition).reduce((config, [key, def]) => {
      const value = element.dataset[key];
      config[key] = this.#parseValue(value, def);
      return config;
    }, {});
  }
  // Converts raw data attribute values to their proper types based on
  // the definition schema, with support for defaults and enums.
  #parseValue(value, definition) {
    if (value === null || value === void 0) {
      return definition.default;
    }
    switch (definition.type) {
      case "string":
        return value;
      case "number":
        const parsedValue = parseInt(value);
        return isNaN(parsedValue) ? definition.default : parsedValue;
      case "boolean":
        return value !== "false";
      case "enum":
        return definition.values.includes(value) ? value : definition.default;
      default:
        return value || definition.default;
    }
  }
  // Creates getter properties directly on the instance for access to
  // configuration values (e.g., config.someValue).
  #setupGetters() {
    Object.keys(this.#config).forEach((key) => {
      Object.defineProperty(this, key, {
        get() {
          return this.#config[key];
        },
        configurable: true,
        enumerable: true
      });
    });
  }
  // Creates getter properties directly on the instance for computed values
  // that depend on one or more configuration values.
  #setupComputed(computed) {
    Object.entries(computed).forEach(([key, fn]) => {
      Object.defineProperty(this, key, {
        get() {
          return fn(this);
        },
        configurable: true,
        enumerable: true
      });
    });
  }
};

// node_modules/.pnpm/@floating-ui+utils@0.2.8/node_modules/@floating-ui/utils/dist/floating-ui.utils.mjs
var min = Math.min;
var max = Math.max;
var round = Math.round;
var floor = Math.floor;
var createCoords = (v) => ({
  x: v,
  y: v
});
var oppositeSideMap = {
  left: "right",
  right: "left",
  bottom: "top",
  top: "bottom"
};
var oppositeAlignmentMap = {
  start: "end",
  end: "start"
};
function clamp(start, value, end) {
  return max(start, min(value, end));
}
function evaluate(value, param) {
  return typeof value === "function" ? value(param) : value;
}
function getSide(placement) {
  return placement.split("-")[0];
}
function getAlignment(placement) {
  return placement.split("-")[1];
}
function getOppositeAxis(axis) {
  return axis === "x" ? "y" : "x";
}
function getAxisLength(axis) {
  return axis === "y" ? "height" : "width";
}
function getSideAxis(placement) {
  return ["top", "bottom"].includes(getSide(placement)) ? "y" : "x";
}
function getAlignmentAxis(placement) {
  return getOppositeAxis(getSideAxis(placement));
}
function getAlignmentSides(placement, rects, rtl) {
  if (rtl === void 0) {
    rtl = false;
  }
  const alignment = getAlignment(placement);
  const alignmentAxis = getAlignmentAxis(placement);
  const length = getAxisLength(alignmentAxis);
  let mainAlignmentSide = alignmentAxis === "x" ? alignment === (rtl ? "end" : "start") ? "right" : "left" : alignment === "start" ? "bottom" : "top";
  if (rects.reference[length] > rects.floating[length]) {
    mainAlignmentSide = getOppositePlacement(mainAlignmentSide);
  }
  return [mainAlignmentSide, getOppositePlacement(mainAlignmentSide)];
}
function getExpandedPlacements(placement) {
  const oppositePlacement = getOppositePlacement(placement);
  return [getOppositeAlignmentPlacement(placement), oppositePlacement, getOppositeAlignmentPlacement(oppositePlacement)];
}
function getOppositeAlignmentPlacement(placement) {
  return placement.replace(/start|end/g, (alignment) => oppositeAlignmentMap[alignment]);
}
function getSideList(side, isStart, rtl) {
  const lr = ["left", "right"];
  const rl = ["right", "left"];
  const tb = ["top", "bottom"];
  const bt = ["bottom", "top"];
  switch (side) {
    case "top":
    case "bottom":
      if (rtl) return isStart ? rl : lr;
      return isStart ? lr : rl;
    case "left":
    case "right":
      return isStart ? tb : bt;
    default:
      return [];
  }
}
function getOppositeAxisPlacements(placement, flipAlignment, direction, rtl) {
  const alignment = getAlignment(placement);
  let list = getSideList(getSide(placement), direction === "start", rtl);
  if (alignment) {
    list = list.map((side) => side + "-" + alignment);
    if (flipAlignment) {
      list = list.concat(list.map(getOppositeAlignmentPlacement));
    }
  }
  return list;
}
function getOppositePlacement(placement) {
  return placement.replace(/left|right|bottom|top/g, (side) => oppositeSideMap[side]);
}
function expandPaddingObject(padding) {
  return {
    top: 0,
    right: 0,
    bottom: 0,
    left: 0,
    ...padding
  };
}
function getPaddingObject(padding) {
  return typeof padding !== "number" ? expandPaddingObject(padding) : {
    top: padding,
    right: padding,
    bottom: padding,
    left: padding
  };
}
function rectToClientRect(rect) {
  const {
    x,
    y,
    width,
    height
  } = rect;
  return {
    width,
    height,
    top: y,
    left: x,
    right: x + width,
    bottom: y + height,
    x,
    y
  };
}

// node_modules/.pnpm/@floating-ui+core@1.6.8/node_modules/@floating-ui/core/dist/floating-ui.core.mjs
function computeCoordsFromPlacement(_ref, placement, rtl) {
  let {
    reference,
    floating
  } = _ref;
  const sideAxis = getSideAxis(placement);
  const alignmentAxis = getAlignmentAxis(placement);
  const alignLength = getAxisLength(alignmentAxis);
  const side = getSide(placement);
  const isVertical = sideAxis === "y";
  const commonX = reference.x + reference.width / 2 - floating.width / 2;
  const commonY = reference.y + reference.height / 2 - floating.height / 2;
  const commonAlign = reference[alignLength] / 2 - floating[alignLength] / 2;
  let coords;
  switch (side) {
    case "top":
      coords = {
        x: commonX,
        y: reference.y - floating.height
      };
      break;
    case "bottom":
      coords = {
        x: commonX,
        y: reference.y + reference.height
      };
      break;
    case "right":
      coords = {
        x: reference.x + reference.width,
        y: commonY
      };
      break;
    case "left":
      coords = {
        x: reference.x - floating.width,
        y: commonY
      };
      break;
    default:
      coords = {
        x: reference.x,
        y: reference.y
      };
  }
  switch (getAlignment(placement)) {
    case "start":
      coords[alignmentAxis] -= commonAlign * (rtl && isVertical ? -1 : 1);
      break;
    case "end":
      coords[alignmentAxis] += commonAlign * (rtl && isVertical ? -1 : 1);
      break;
  }
  return coords;
}
var computePosition = async (reference, floating, config) => {
  const {
    placement = "bottom",
    strategy = "absolute",
    middleware = [],
    platform: platform2
  } = config;
  const validMiddleware = middleware.filter(Boolean);
  const rtl = await (platform2.isRTL == null ? void 0 : platform2.isRTL(floating));
  let rects = await platform2.getElementRects({
    reference,
    floating,
    strategy
  });
  let {
    x,
    y
  } = computeCoordsFromPlacement(rects, placement, rtl);
  let statefulPlacement = placement;
  let middlewareData = {};
  let resetCount = 0;
  for (let i = 0; i < validMiddleware.length; i++) {
    const {
      name,
      fn
    } = validMiddleware[i];
    const {
      x: nextX,
      y: nextY,
      data,
      reset
    } = await fn({
      x,
      y,
      initialPlacement: placement,
      placement: statefulPlacement,
      strategy,
      middlewareData,
      rects,
      platform: platform2,
      elements: {
        reference,
        floating
      }
    });
    x = nextX != null ? nextX : x;
    y = nextY != null ? nextY : y;
    middlewareData = {
      ...middlewareData,
      [name]: {
        ...middlewareData[name],
        ...data
      }
    };
    if (reset && resetCount <= 50) {
      resetCount++;
      if (typeof reset === "object") {
        if (reset.placement) {
          statefulPlacement = reset.placement;
        }
        if (reset.rects) {
          rects = reset.rects === true ? await platform2.getElementRects({
            reference,
            floating,
            strategy
          }) : reset.rects;
        }
        ({
          x,
          y
        } = computeCoordsFromPlacement(rects, statefulPlacement, rtl));
      }
      i = -1;
    }
  }
  return {
    x,
    y,
    placement: statefulPlacement,
    strategy,
    middlewareData
  };
};
async function detectOverflow(state, options) {
  var _await$platform$isEle;
  if (options === void 0) {
    options = {};
  }
  const {
    x,
    y,
    platform: platform2,
    rects,
    elements,
    strategy
  } = state;
  const {
    boundary = "clippingAncestors",
    rootBoundary = "viewport",
    elementContext = "floating",
    altBoundary = false,
    padding = 0
  } = evaluate(options, state);
  const paddingObject = getPaddingObject(padding);
  const altContext = elementContext === "floating" ? "reference" : "floating";
  const element = elements[altBoundary ? altContext : elementContext];
  const clippingClientRect = rectToClientRect(await platform2.getClippingRect({
    element: ((_await$platform$isEle = await (platform2.isElement == null ? void 0 : platform2.isElement(element))) != null ? _await$platform$isEle : true) ? element : element.contextElement || await (platform2.getDocumentElement == null ? void 0 : platform2.getDocumentElement(elements.floating)),
    boundary,
    rootBoundary,
    strategy
  }));
  const rect = elementContext === "floating" ? {
    x,
    y,
    width: rects.floating.width,
    height: rects.floating.height
  } : rects.reference;
  const offsetParent = await (platform2.getOffsetParent == null ? void 0 : platform2.getOffsetParent(elements.floating));
  const offsetScale = await (platform2.isElement == null ? void 0 : platform2.isElement(offsetParent)) ? await (platform2.getScale == null ? void 0 : platform2.getScale(offsetParent)) || {
    x: 1,
    y: 1
  } : {
    x: 1,
    y: 1
  };
  const elementClientRect = rectToClientRect(platform2.convertOffsetParentRelativeRectToViewportRelativeRect ? await platform2.convertOffsetParentRelativeRectToViewportRelativeRect({
    elements,
    rect,
    offsetParent,
    strategy
  }) : rect);
  return {
    top: (clippingClientRect.top - elementClientRect.top + paddingObject.top) / offsetScale.y,
    bottom: (elementClientRect.bottom - clippingClientRect.bottom + paddingObject.bottom) / offsetScale.y,
    left: (clippingClientRect.left - elementClientRect.left + paddingObject.left) / offsetScale.x,
    right: (elementClientRect.right - clippingClientRect.right + paddingObject.right) / offsetScale.x
  };
}
var arrow = (options) => ({
  name: "arrow",
  options,
  async fn(state) {
    const {
      x,
      y,
      placement,
      rects,
      platform: platform2,
      elements,
      middlewareData
    } = state;
    const {
      element,
      padding = 0
    } = evaluate(options, state) || {};
    if (element == null) {
      return {};
    }
    const paddingObject = getPaddingObject(padding);
    const coords = {
      x,
      y
    };
    const axis = getAlignmentAxis(placement);
    const length = getAxisLength(axis);
    const arrowDimensions = await platform2.getDimensions(element);
    const isYAxis = axis === "y";
    const minProp = isYAxis ? "top" : "left";
    const maxProp = isYAxis ? "bottom" : "right";
    const clientProp = isYAxis ? "clientHeight" : "clientWidth";
    const endDiff = rects.reference[length] + rects.reference[axis] - coords[axis] - rects.floating[length];
    const startDiff = coords[axis] - rects.reference[axis];
    const arrowOffsetParent = await (platform2.getOffsetParent == null ? void 0 : platform2.getOffsetParent(element));
    let clientSize = arrowOffsetParent ? arrowOffsetParent[clientProp] : 0;
    if (!clientSize || !await (platform2.isElement == null ? void 0 : platform2.isElement(arrowOffsetParent))) {
      clientSize = elements.floating[clientProp] || rects.floating[length];
    }
    const centerToReference = endDiff / 2 - startDiff / 2;
    const largestPossiblePadding = clientSize / 2 - arrowDimensions[length] / 2 - 1;
    const minPadding = min(paddingObject[minProp], largestPossiblePadding);
    const maxPadding = min(paddingObject[maxProp], largestPossiblePadding);
    const min$1 = minPadding;
    const max2 = clientSize - arrowDimensions[length] - maxPadding;
    const center = clientSize / 2 - arrowDimensions[length] / 2 + centerToReference;
    const offset3 = clamp(min$1, center, max2);
    const shouldAddOffset = !middlewareData.arrow && getAlignment(placement) != null && center !== offset3 && rects.reference[length] / 2 - (center < min$1 ? minPadding : maxPadding) - arrowDimensions[length] / 2 < 0;
    const alignmentOffset = shouldAddOffset ? center < min$1 ? center - min$1 : center - max2 : 0;
    return {
      [axis]: coords[axis] + alignmentOffset,
      data: {
        [axis]: offset3,
        centerOffset: center - offset3 - alignmentOffset,
        ...shouldAddOffset && {
          alignmentOffset
        }
      },
      reset: shouldAddOffset
    };
  }
});
var flip = function(options) {
  if (options === void 0) {
    options = {};
  }
  return {
    name: "flip",
    options,
    async fn(state) {
      var _middlewareData$arrow, _middlewareData$flip;
      const {
        placement,
        middlewareData,
        rects,
        initialPlacement,
        platform: platform2,
        elements
      } = state;
      const {
        mainAxis: checkMainAxis = true,
        crossAxis: checkCrossAxis = true,
        fallbackPlacements: specifiedFallbackPlacements,
        fallbackStrategy = "bestFit",
        fallbackAxisSideDirection = "none",
        flipAlignment = true,
        ...detectOverflowOptions
      } = evaluate(options, state);
      if ((_middlewareData$arrow = middlewareData.arrow) != null && _middlewareData$arrow.alignmentOffset) {
        return {};
      }
      const side = getSide(placement);
      const initialSideAxis = getSideAxis(initialPlacement);
      const isBasePlacement = getSide(initialPlacement) === initialPlacement;
      const rtl = await (platform2.isRTL == null ? void 0 : platform2.isRTL(elements.floating));
      const fallbackPlacements = specifiedFallbackPlacements || (isBasePlacement || !flipAlignment ? [getOppositePlacement(initialPlacement)] : getExpandedPlacements(initialPlacement));
      const hasFallbackAxisSideDirection = fallbackAxisSideDirection !== "none";
      if (!specifiedFallbackPlacements && hasFallbackAxisSideDirection) {
        fallbackPlacements.push(...getOppositeAxisPlacements(initialPlacement, flipAlignment, fallbackAxisSideDirection, rtl));
      }
      const placements2 = [initialPlacement, ...fallbackPlacements];
      const overflow = await detectOverflow(state, detectOverflowOptions);
      const overflows = [];
      let overflowsData = ((_middlewareData$flip = middlewareData.flip) == null ? void 0 : _middlewareData$flip.overflows) || [];
      if (checkMainAxis) {
        overflows.push(overflow[side]);
      }
      if (checkCrossAxis) {
        const sides2 = getAlignmentSides(placement, rects, rtl);
        overflows.push(overflow[sides2[0]], overflow[sides2[1]]);
      }
      overflowsData = [...overflowsData, {
        placement,
        overflows
      }];
      if (!overflows.every((side2) => side2 <= 0)) {
        var _middlewareData$flip2, _overflowsData$filter;
        const nextIndex = (((_middlewareData$flip2 = middlewareData.flip) == null ? void 0 : _middlewareData$flip2.index) || 0) + 1;
        const nextPlacement = placements2[nextIndex];
        if (nextPlacement) {
          return {
            data: {
              index: nextIndex,
              overflows: overflowsData
            },
            reset: {
              placement: nextPlacement
            }
          };
        }
        let resetPlacement = (_overflowsData$filter = overflowsData.filter((d) => d.overflows[0] <= 0).sort((a, b) => a.overflows[1] - b.overflows[1])[0]) == null ? void 0 : _overflowsData$filter.placement;
        if (!resetPlacement) {
          switch (fallbackStrategy) {
            case "bestFit": {
              var _overflowsData$filter2;
              const placement2 = (_overflowsData$filter2 = overflowsData.filter((d) => {
                if (hasFallbackAxisSideDirection) {
                  const currentSideAxis = getSideAxis(d.placement);
                  return currentSideAxis === initialSideAxis || // Create a bias to the `y` side axis due to horizontal
                  // reading directions favoring greater width.
                  currentSideAxis === "y";
                }
                return true;
              }).map((d) => [d.placement, d.overflows.filter((overflow2) => overflow2 > 0).reduce((acc, overflow2) => acc + overflow2, 0)]).sort((a, b) => a[1] - b[1])[0]) == null ? void 0 : _overflowsData$filter2[0];
              if (placement2) {
                resetPlacement = placement2;
              }
              break;
            }
            case "initialPlacement":
              resetPlacement = initialPlacement;
              break;
          }
        }
        if (placement !== resetPlacement) {
          return {
            reset: {
              placement: resetPlacement
            }
          };
        }
      }
      return {};
    }
  };
};
function getBoundingRect(rects) {
  const minX = min(...rects.map((rect) => rect.left));
  const minY = min(...rects.map((rect) => rect.top));
  const maxX = max(...rects.map((rect) => rect.right));
  const maxY = max(...rects.map((rect) => rect.bottom));
  return {
    x: minX,
    y: minY,
    width: maxX - minX,
    height: maxY - minY
  };
}
function getRectsByLine(rects) {
  const sortedRects = rects.slice().sort((a, b) => a.y - b.y);
  const groups = [];
  let prevRect = null;
  for (let i = 0; i < sortedRects.length; i++) {
    const rect = sortedRects[i];
    if (!prevRect || rect.y - prevRect.y > prevRect.height / 2) {
      groups.push([rect]);
    } else {
      groups[groups.length - 1].push(rect);
    }
    prevRect = rect;
  }
  return groups.map((rect) => rectToClientRect(getBoundingRect(rect)));
}
var inline = function(options) {
  if (options === void 0) {
    options = {};
  }
  return {
    name: "inline",
    options,
    async fn(state) {
      const {
        placement,
        elements,
        rects,
        platform: platform2,
        strategy
      } = state;
      const {
        padding = 2,
        x,
        y
      } = evaluate(options, state);
      const nativeClientRects = Array.from(await (platform2.getClientRects == null ? void 0 : platform2.getClientRects(elements.reference)) || []);
      const clientRects = getRectsByLine(nativeClientRects);
      const fallback = rectToClientRect(getBoundingRect(nativeClientRects));
      const paddingObject = getPaddingObject(padding);
      function getBoundingClientRect2() {
        if (clientRects.length === 2 && clientRects[0].left > clientRects[1].right && x != null && y != null) {
          return clientRects.find((rect) => x > rect.left - paddingObject.left && x < rect.right + paddingObject.right && y > rect.top - paddingObject.top && y < rect.bottom + paddingObject.bottom) || fallback;
        }
        if (clientRects.length >= 2) {
          if (getSideAxis(placement) === "y") {
            const firstRect = clientRects[0];
            const lastRect = clientRects[clientRects.length - 1];
            const isTop = getSide(placement) === "top";
            const top2 = firstRect.top;
            const bottom2 = lastRect.bottom;
            const left2 = isTop ? firstRect.left : lastRect.left;
            const right2 = isTop ? firstRect.right : lastRect.right;
            const width2 = right2 - left2;
            const height2 = bottom2 - top2;
            return {
              top: top2,
              bottom: bottom2,
              left: left2,
              right: right2,
              width: width2,
              height: height2,
              x: left2,
              y: top2
            };
          }
          const isLeftSide = getSide(placement) === "left";
          const maxRight = max(...clientRects.map((rect) => rect.right));
          const minLeft = min(...clientRects.map((rect) => rect.left));
          const measureRects = clientRects.filter((rect) => isLeftSide ? rect.left === minLeft : rect.right === maxRight);
          const top = measureRects[0].top;
          const bottom = measureRects[measureRects.length - 1].bottom;
          const left = minLeft;
          const right = maxRight;
          const width = right - left;
          const height = bottom - top;
          return {
            top,
            bottom,
            left,
            right,
            width,
            height,
            x: left,
            y: top
          };
        }
        return fallback;
      }
      const resetRects = await platform2.getElementRects({
        reference: {
          getBoundingClientRect: getBoundingClientRect2
        },
        floating: elements.floating,
        strategy
      });
      if (rects.reference.x !== resetRects.reference.x || rects.reference.y !== resetRects.reference.y || rects.reference.width !== resetRects.reference.width || rects.reference.height !== resetRects.reference.height) {
        return {
          reset: {
            rects: resetRects
          }
        };
      }
      return {};
    }
  };
};
async function convertValueToCoords(state, options) {
  const {
    placement,
    platform: platform2,
    elements
  } = state;
  const rtl = await (platform2.isRTL == null ? void 0 : platform2.isRTL(elements.floating));
  const side = getSide(placement);
  const alignment = getAlignment(placement);
  const isVertical = getSideAxis(placement) === "y";
  const mainAxisMulti = ["left", "top"].includes(side) ? -1 : 1;
  const crossAxisMulti = rtl && isVertical ? -1 : 1;
  const rawValue = evaluate(options, state);
  let {
    mainAxis,
    crossAxis,
    alignmentAxis
  } = typeof rawValue === "number" ? {
    mainAxis: rawValue,
    crossAxis: 0,
    alignmentAxis: null
  } : {
    mainAxis: rawValue.mainAxis || 0,
    crossAxis: rawValue.crossAxis || 0,
    alignmentAxis: rawValue.alignmentAxis
  };
  if (alignment && typeof alignmentAxis === "number") {
    crossAxis = alignment === "end" ? alignmentAxis * -1 : alignmentAxis;
  }
  return isVertical ? {
    x: crossAxis * crossAxisMulti,
    y: mainAxis * mainAxisMulti
  } : {
    x: mainAxis * mainAxisMulti,
    y: crossAxis * crossAxisMulti
  };
}
var offset = function(options) {
  if (options === void 0) {
    options = 0;
  }
  return {
    name: "offset",
    options,
    async fn(state) {
      var _middlewareData$offse, _middlewareData$arrow;
      const {
        x,
        y,
        placement,
        middlewareData
      } = state;
      const diffCoords = await convertValueToCoords(state, options);
      if (placement === ((_middlewareData$offse = middlewareData.offset) == null ? void 0 : _middlewareData$offse.placement) && (_middlewareData$arrow = middlewareData.arrow) != null && _middlewareData$arrow.alignmentOffset) {
        return {};
      }
      return {
        x: x + diffCoords.x,
        y: y + diffCoords.y,
        data: {
          ...diffCoords,
          placement
        }
      };
    }
  };
};
var shift = function(options) {
  if (options === void 0) {
    options = {};
  }
  return {
    name: "shift",
    options,
    async fn(state) {
      const {
        x,
        y,
        placement
      } = state;
      const {
        mainAxis: checkMainAxis = true,
        crossAxis: checkCrossAxis = false,
        limiter = {
          fn: (_ref) => {
            let {
              x: x2,
              y: y2
            } = _ref;
            return {
              x: x2,
              y: y2
            };
          }
        },
        ...detectOverflowOptions
      } = evaluate(options, state);
      const coords = {
        x,
        y
      };
      const overflow = await detectOverflow(state, detectOverflowOptions);
      const crossAxis = getSideAxis(getSide(placement));
      const mainAxis = getOppositeAxis(crossAxis);
      let mainAxisCoord = coords[mainAxis];
      let crossAxisCoord = coords[crossAxis];
      if (checkMainAxis) {
        const minSide = mainAxis === "y" ? "top" : "left";
        const maxSide = mainAxis === "y" ? "bottom" : "right";
        const min2 = mainAxisCoord + overflow[minSide];
        const max2 = mainAxisCoord - overflow[maxSide];
        mainAxisCoord = clamp(min2, mainAxisCoord, max2);
      }
      if (checkCrossAxis) {
        const minSide = crossAxis === "y" ? "top" : "left";
        const maxSide = crossAxis === "y" ? "bottom" : "right";
        const min2 = crossAxisCoord + overflow[minSide];
        const max2 = crossAxisCoord - overflow[maxSide];
        crossAxisCoord = clamp(min2, crossAxisCoord, max2);
      }
      const limitedCoords = limiter.fn({
        ...state,
        [mainAxis]: mainAxisCoord,
        [crossAxis]: crossAxisCoord
      });
      return {
        ...limitedCoords,
        data: {
          x: limitedCoords.x - x,
          y: limitedCoords.y - y,
          enabled: {
            [mainAxis]: checkMainAxis,
            [crossAxis]: checkCrossAxis
          }
        }
      };
    }
  };
};
var size = function(options) {
  if (options === void 0) {
    options = {};
  }
  return {
    name: "size",
    options,
    async fn(state) {
      var _state$middlewareData, _state$middlewareData2;
      const {
        placement,
        rects,
        platform: platform2,
        elements
      } = state;
      const {
        apply = () => {
        },
        ...detectOverflowOptions
      } = evaluate(options, state);
      const overflow = await detectOverflow(state, detectOverflowOptions);
      const side = getSide(placement);
      const alignment = getAlignment(placement);
      const isYAxis = getSideAxis(placement) === "y";
      const {
        width,
        height
      } = rects.floating;
      let heightSide;
      let widthSide;
      if (side === "top" || side === "bottom") {
        heightSide = side;
        widthSide = alignment === (await (platform2.isRTL == null ? void 0 : platform2.isRTL(elements.floating)) ? "start" : "end") ? "left" : "right";
      } else {
        widthSide = side;
        heightSide = alignment === "end" ? "top" : "bottom";
      }
      const maximumClippingHeight = height - overflow.top - overflow.bottom;
      const maximumClippingWidth = width - overflow.left - overflow.right;
      const overflowAvailableHeight = min(height - overflow[heightSide], maximumClippingHeight);
      const overflowAvailableWidth = min(width - overflow[widthSide], maximumClippingWidth);
      const noShift = !state.middlewareData.shift;
      let availableHeight = overflowAvailableHeight;
      let availableWidth = overflowAvailableWidth;
      if ((_state$middlewareData = state.middlewareData.shift) != null && _state$middlewareData.enabled.x) {
        availableWidth = maximumClippingWidth;
      }
      if ((_state$middlewareData2 = state.middlewareData.shift) != null && _state$middlewareData2.enabled.y) {
        availableHeight = maximumClippingHeight;
      }
      if (noShift && !alignment) {
        const xMin = max(overflow.left, 0);
        const xMax = max(overflow.right, 0);
        const yMin = max(overflow.top, 0);
        const yMax = max(overflow.bottom, 0);
        if (isYAxis) {
          availableWidth = width - 2 * (xMin !== 0 || xMax !== 0 ? xMin + xMax : max(overflow.left, overflow.right));
        } else {
          availableHeight = height - 2 * (yMin !== 0 || yMax !== 0 ? yMin + yMax : max(overflow.top, overflow.bottom));
        }
      }
      await apply({
        ...state,
        availableWidth,
        availableHeight
      });
      const nextDimensions = await platform2.getDimensions(elements.floating);
      if (width !== nextDimensions.width || height !== nextDimensions.height) {
        return {
          reset: {
            rects: true
          }
        };
      }
      return {};
    }
  };
};

// node_modules/.pnpm/@floating-ui+utils@0.2.8/node_modules/@floating-ui/utils/dist/floating-ui.utils.dom.mjs
function hasWindow() {
  return typeof window !== "undefined";
}
function getNodeName(node) {
  if (isNode(node)) {
    return (node.nodeName || "").toLowerCase();
  }
  return "#document";
}
function getWindow(node) {
  var _node$ownerDocument;
  return (node == null || (_node$ownerDocument = node.ownerDocument) == null ? void 0 : _node$ownerDocument.defaultView) || window;
}
function getDocumentElement(node) {
  var _ref;
  return (_ref = (isNode(node) ? node.ownerDocument : node.document) || window.document) == null ? void 0 : _ref.documentElement;
}
function isNode(value) {
  if (!hasWindow()) {
    return false;
  }
  return value instanceof Node || value instanceof getWindow(value).Node;
}
function isElement(value) {
  if (!hasWindow()) {
    return false;
  }
  return value instanceof Element || value instanceof getWindow(value).Element;
}
function isHTMLElement(value) {
  if (!hasWindow()) {
    return false;
  }
  return value instanceof HTMLElement || value instanceof getWindow(value).HTMLElement;
}
function isShadowRoot(value) {
  if (!hasWindow() || typeof ShadowRoot === "undefined") {
    return false;
  }
  return value instanceof ShadowRoot || value instanceof getWindow(value).ShadowRoot;
}
function isOverflowElement(element) {
  const {
    overflow,
    overflowX,
    overflowY,
    display
  } = getComputedStyle(element);
  return /auto|scroll|overlay|hidden|clip/.test(overflow + overflowY + overflowX) && !["inline", "contents"].includes(display);
}
function isTableElement(element) {
  return ["table", "td", "th"].includes(getNodeName(element));
}
function isTopLayer(element) {
  return [":popover-open", ":modal"].some((selector) => {
    try {
      return element.matches(selector);
    } catch (e) {
      return false;
    }
  });
}
function isContainingBlock(elementOrCss) {
  const webkit = isWebKit();
  const css = isElement(elementOrCss) ? getComputedStyle(elementOrCss) : elementOrCss;
  return css.transform !== "none" || css.perspective !== "none" || (css.containerType ? css.containerType !== "normal" : false) || !webkit && (css.backdropFilter ? css.backdropFilter !== "none" : false) || !webkit && (css.filter ? css.filter !== "none" : false) || ["transform", "perspective", "filter"].some((value) => (css.willChange || "").includes(value)) || ["paint", "layout", "strict", "content"].some((value) => (css.contain || "").includes(value));
}
function getContainingBlock(element) {
  let currentNode = getParentNode(element);
  while (isHTMLElement(currentNode) && !isLastTraversableNode(currentNode)) {
    if (isContainingBlock(currentNode)) {
      return currentNode;
    } else if (isTopLayer(currentNode)) {
      return null;
    }
    currentNode = getParentNode(currentNode);
  }
  return null;
}
function isWebKit() {
  if (typeof CSS === "undefined" || !CSS.supports) return false;
  return CSS.supports("-webkit-backdrop-filter", "none");
}
function isLastTraversableNode(node) {
  return ["html", "body", "#document"].includes(getNodeName(node));
}
function getComputedStyle(element) {
  return getWindow(element).getComputedStyle(element);
}
function getNodeScroll(element) {
  if (isElement(element)) {
    return {
      scrollLeft: element.scrollLeft,
      scrollTop: element.scrollTop
    };
  }
  return {
    scrollLeft: element.scrollX,
    scrollTop: element.scrollY
  };
}
function getParentNode(node) {
  if (getNodeName(node) === "html") {
    return node;
  }
  const result = (
    // Step into the shadow DOM of the parent of a slotted node.
    node.assignedSlot || // DOM Element detected.
    node.parentNode || // ShadowRoot detected.
    isShadowRoot(node) && node.host || // Fallback.
    getDocumentElement(node)
  );
  return isShadowRoot(result) ? result.host : result;
}
function getNearestOverflowAncestor(node) {
  const parentNode = getParentNode(node);
  if (isLastTraversableNode(parentNode)) {
    return node.ownerDocument ? node.ownerDocument.body : node.body;
  }
  if (isHTMLElement(parentNode) && isOverflowElement(parentNode)) {
    return parentNode;
  }
  return getNearestOverflowAncestor(parentNode);
}
function getOverflowAncestors(node, list, traverseIframes) {
  var _node$ownerDocument2;
  if (list === void 0) {
    list = [];
  }
  if (traverseIframes === void 0) {
    traverseIframes = true;
  }
  const scrollableAncestor = getNearestOverflowAncestor(node);
  const isBody = scrollableAncestor === ((_node$ownerDocument2 = node.ownerDocument) == null ? void 0 : _node$ownerDocument2.body);
  const win = getWindow(scrollableAncestor);
  if (isBody) {
    const frameElement = getFrameElement(win);
    return list.concat(win, win.visualViewport || [], isOverflowElement(scrollableAncestor) ? scrollableAncestor : [], frameElement && traverseIframes ? getOverflowAncestors(frameElement) : []);
  }
  return list.concat(scrollableAncestor, getOverflowAncestors(scrollableAncestor, [], traverseIframes));
}
function getFrameElement(win) {
  return win.parent && Object.getPrototypeOf(win.parent) ? win.frameElement : null;
}

// node_modules/.pnpm/@floating-ui+dom@1.6.12/node_modules/@floating-ui/dom/dist/floating-ui.dom.mjs
function getCssDimensions(element) {
  const css = getComputedStyle(element);
  let width = parseFloat(css.width) || 0;
  let height = parseFloat(css.height) || 0;
  const hasOffset = isHTMLElement(element);
  const offsetWidth = hasOffset ? element.offsetWidth : width;
  const offsetHeight = hasOffset ? element.offsetHeight : height;
  const shouldFallback = round(width) !== offsetWidth || round(height) !== offsetHeight;
  if (shouldFallback) {
    width = offsetWidth;
    height = offsetHeight;
  }
  return {
    width,
    height,
    $: shouldFallback
  };
}
function unwrapElement(element) {
  return !isElement(element) ? element.contextElement : element;
}
function getScale(element) {
  const domElement = unwrapElement(element);
  if (!isHTMLElement(domElement)) {
    return createCoords(1);
  }
  const rect = domElement.getBoundingClientRect();
  const {
    width,
    height,
    $
  } = getCssDimensions(domElement);
  let x = ($ ? round(rect.width) : rect.width) / width;
  let y = ($ ? round(rect.height) : rect.height) / height;
  if (!x || !Number.isFinite(x)) {
    x = 1;
  }
  if (!y || !Number.isFinite(y)) {
    y = 1;
  }
  return {
    x,
    y
  };
}
var noOffsets = /* @__PURE__ */ createCoords(0);
function getVisualOffsets(element) {
  const win = getWindow(element);
  if (!isWebKit() || !win.visualViewport) {
    return noOffsets;
  }
  return {
    x: win.visualViewport.offsetLeft,
    y: win.visualViewport.offsetTop
  };
}
function shouldAddVisualOffsets(element, isFixed, floatingOffsetParent) {
  if (isFixed === void 0) {
    isFixed = false;
  }
  if (!floatingOffsetParent || isFixed && floatingOffsetParent !== getWindow(element)) {
    return false;
  }
  return isFixed;
}
function getBoundingClientRect(element, includeScale, isFixedStrategy, offsetParent) {
  if (includeScale === void 0) {
    includeScale = false;
  }
  if (isFixedStrategy === void 0) {
    isFixedStrategy = false;
  }
  const clientRect = element.getBoundingClientRect();
  const domElement = unwrapElement(element);
  let scale = createCoords(1);
  if (includeScale) {
    if (offsetParent) {
      if (isElement(offsetParent)) {
        scale = getScale(offsetParent);
      }
    } else {
      scale = getScale(element);
    }
  }
  const visualOffsets = shouldAddVisualOffsets(domElement, isFixedStrategy, offsetParent) ? getVisualOffsets(domElement) : createCoords(0);
  let x = (clientRect.left + visualOffsets.x) / scale.x;
  let y = (clientRect.top + visualOffsets.y) / scale.y;
  let width = clientRect.width / scale.x;
  let height = clientRect.height / scale.y;
  if (domElement) {
    const win = getWindow(domElement);
    const offsetWin = offsetParent && isElement(offsetParent) ? getWindow(offsetParent) : offsetParent;
    let currentWin = win;
    let currentIFrame = getFrameElement(currentWin);
    while (currentIFrame && offsetParent && offsetWin !== currentWin) {
      const iframeScale = getScale(currentIFrame);
      const iframeRect = currentIFrame.getBoundingClientRect();
      const css = getComputedStyle(currentIFrame);
      const left = iframeRect.left + (currentIFrame.clientLeft + parseFloat(css.paddingLeft)) * iframeScale.x;
      const top = iframeRect.top + (currentIFrame.clientTop + parseFloat(css.paddingTop)) * iframeScale.y;
      x *= iframeScale.x;
      y *= iframeScale.y;
      width *= iframeScale.x;
      height *= iframeScale.y;
      x += left;
      y += top;
      currentWin = getWindow(currentIFrame);
      currentIFrame = getFrameElement(currentWin);
    }
  }
  return rectToClientRect({
    width,
    height,
    x,
    y
  });
}
function getWindowScrollBarX(element, rect) {
  const leftScroll = getNodeScroll(element).scrollLeft;
  if (!rect) {
    return getBoundingClientRect(getDocumentElement(element)).left + leftScroll;
  }
  return rect.left + leftScroll;
}
function getHTMLOffset(documentElement, scroll, ignoreScrollbarX) {
  if (ignoreScrollbarX === void 0) {
    ignoreScrollbarX = false;
  }
  const htmlRect = documentElement.getBoundingClientRect();
  const x = htmlRect.left + scroll.scrollLeft - (ignoreScrollbarX ? 0 : (
    // RTL <body> scrollbar.
    getWindowScrollBarX(documentElement, htmlRect)
  ));
  const y = htmlRect.top + scroll.scrollTop;
  return {
    x,
    y
  };
}
function convertOffsetParentRelativeRectToViewportRelativeRect(_ref) {
  let {
    elements,
    rect,
    offsetParent,
    strategy
  } = _ref;
  const isFixed = strategy === "fixed";
  const documentElement = getDocumentElement(offsetParent);
  const topLayer = elements ? isTopLayer(elements.floating) : false;
  if (offsetParent === documentElement || topLayer && isFixed) {
    return rect;
  }
  let scroll = {
    scrollLeft: 0,
    scrollTop: 0
  };
  let scale = createCoords(1);
  const offsets = createCoords(0);
  const isOffsetParentAnElement = isHTMLElement(offsetParent);
  if (isOffsetParentAnElement || !isOffsetParentAnElement && !isFixed) {
    if (getNodeName(offsetParent) !== "body" || isOverflowElement(documentElement)) {
      scroll = getNodeScroll(offsetParent);
    }
    if (isHTMLElement(offsetParent)) {
      const offsetRect = getBoundingClientRect(offsetParent);
      scale = getScale(offsetParent);
      offsets.x = offsetRect.x + offsetParent.clientLeft;
      offsets.y = offsetRect.y + offsetParent.clientTop;
    }
  }
  const htmlOffset = documentElement && !isOffsetParentAnElement && !isFixed ? getHTMLOffset(documentElement, scroll, true) : createCoords(0);
  return {
    width: rect.width * scale.x,
    height: rect.height * scale.y,
    x: rect.x * scale.x - scroll.scrollLeft * scale.x + offsets.x + htmlOffset.x,
    y: rect.y * scale.y - scroll.scrollTop * scale.y + offsets.y + htmlOffset.y
  };
}
function getClientRects(element) {
  return Array.from(element.getClientRects());
}
function getDocumentRect(element) {
  const html = getDocumentElement(element);
  const scroll = getNodeScroll(element);
  const body = element.ownerDocument.body;
  const width = max(html.scrollWidth, html.clientWidth, body.scrollWidth, body.clientWidth);
  const height = max(html.scrollHeight, html.clientHeight, body.scrollHeight, body.clientHeight);
  let x = -scroll.scrollLeft + getWindowScrollBarX(element);
  const y = -scroll.scrollTop;
  if (getComputedStyle(body).direction === "rtl") {
    x += max(html.clientWidth, body.clientWidth) - width;
  }
  return {
    width,
    height,
    x,
    y
  };
}
function getViewportRect(element, strategy) {
  const win = getWindow(element);
  const html = getDocumentElement(element);
  const visualViewport = win.visualViewport;
  let width = html.clientWidth;
  let height = html.clientHeight;
  let x = 0;
  let y = 0;
  if (visualViewport) {
    width = visualViewport.width;
    height = visualViewport.height;
    const visualViewportBased = isWebKit();
    if (!visualViewportBased || visualViewportBased && strategy === "fixed") {
      x = visualViewport.offsetLeft;
      y = visualViewport.offsetTop;
    }
  }
  return {
    width,
    height,
    x,
    y
  };
}
function getInnerBoundingClientRect(element, strategy) {
  const clientRect = getBoundingClientRect(element, true, strategy === "fixed");
  const top = clientRect.top + element.clientTop;
  const left = clientRect.left + element.clientLeft;
  const scale = isHTMLElement(element) ? getScale(element) : createCoords(1);
  const width = element.clientWidth * scale.x;
  const height = element.clientHeight * scale.y;
  const x = left * scale.x;
  const y = top * scale.y;
  return {
    width,
    height,
    x,
    y
  };
}
function getClientRectFromClippingAncestor(element, clippingAncestor, strategy) {
  let rect;
  if (clippingAncestor === "viewport") {
    rect = getViewportRect(element, strategy);
  } else if (clippingAncestor === "document") {
    rect = getDocumentRect(getDocumentElement(element));
  } else if (isElement(clippingAncestor)) {
    rect = getInnerBoundingClientRect(clippingAncestor, strategy);
  } else {
    const visualOffsets = getVisualOffsets(element);
    rect = {
      x: clippingAncestor.x - visualOffsets.x,
      y: clippingAncestor.y - visualOffsets.y,
      width: clippingAncestor.width,
      height: clippingAncestor.height
    };
  }
  return rectToClientRect(rect);
}
function hasFixedPositionAncestor(element, stopNode) {
  const parentNode = getParentNode(element);
  if (parentNode === stopNode || !isElement(parentNode) || isLastTraversableNode(parentNode)) {
    return false;
  }
  return getComputedStyle(parentNode).position === "fixed" || hasFixedPositionAncestor(parentNode, stopNode);
}
function getClippingElementAncestors(element, cache) {
  const cachedResult = cache.get(element);
  if (cachedResult) {
    return cachedResult;
  }
  let result = getOverflowAncestors(element, [], false).filter((el) => isElement(el) && getNodeName(el) !== "body");
  let currentContainingBlockComputedStyle = null;
  const elementIsFixed = getComputedStyle(element).position === "fixed";
  let currentNode = elementIsFixed ? getParentNode(element) : element;
  while (isElement(currentNode) && !isLastTraversableNode(currentNode)) {
    const computedStyle = getComputedStyle(currentNode);
    const currentNodeIsContaining = isContainingBlock(currentNode);
    if (!currentNodeIsContaining && computedStyle.position === "fixed") {
      currentContainingBlockComputedStyle = null;
    }
    const shouldDropCurrentNode = elementIsFixed ? !currentNodeIsContaining && !currentContainingBlockComputedStyle : !currentNodeIsContaining && computedStyle.position === "static" && !!currentContainingBlockComputedStyle && ["absolute", "fixed"].includes(currentContainingBlockComputedStyle.position) || isOverflowElement(currentNode) && !currentNodeIsContaining && hasFixedPositionAncestor(element, currentNode);
    if (shouldDropCurrentNode) {
      result = result.filter((ancestor) => ancestor !== currentNode);
    } else {
      currentContainingBlockComputedStyle = computedStyle;
    }
    currentNode = getParentNode(currentNode);
  }
  cache.set(element, result);
  return result;
}
function getClippingRect(_ref) {
  let {
    element,
    boundary,
    rootBoundary,
    strategy
  } = _ref;
  const elementClippingAncestors = boundary === "clippingAncestors" ? isTopLayer(element) ? [] : getClippingElementAncestors(element, this._c) : [].concat(boundary);
  const clippingAncestors = [...elementClippingAncestors, rootBoundary];
  const firstClippingAncestor = clippingAncestors[0];
  const clippingRect = clippingAncestors.reduce((accRect, clippingAncestor) => {
    const rect = getClientRectFromClippingAncestor(element, clippingAncestor, strategy);
    accRect.top = max(rect.top, accRect.top);
    accRect.right = min(rect.right, accRect.right);
    accRect.bottom = min(rect.bottom, accRect.bottom);
    accRect.left = max(rect.left, accRect.left);
    return accRect;
  }, getClientRectFromClippingAncestor(element, firstClippingAncestor, strategy));
  return {
    width: clippingRect.right - clippingRect.left,
    height: clippingRect.bottom - clippingRect.top,
    x: clippingRect.left,
    y: clippingRect.top
  };
}
function getDimensions(element) {
  const {
    width,
    height
  } = getCssDimensions(element);
  return {
    width,
    height
  };
}
function getRectRelativeToOffsetParent(element, offsetParent, strategy) {
  const isOffsetParentAnElement = isHTMLElement(offsetParent);
  const documentElement = getDocumentElement(offsetParent);
  const isFixed = strategy === "fixed";
  const rect = getBoundingClientRect(element, true, isFixed, offsetParent);
  let scroll = {
    scrollLeft: 0,
    scrollTop: 0
  };
  const offsets = createCoords(0);
  if (isOffsetParentAnElement || !isOffsetParentAnElement && !isFixed) {
    if (getNodeName(offsetParent) !== "body" || isOverflowElement(documentElement)) {
      scroll = getNodeScroll(offsetParent);
    }
    if (isOffsetParentAnElement) {
      const offsetRect = getBoundingClientRect(offsetParent, true, isFixed, offsetParent);
      offsets.x = offsetRect.x + offsetParent.clientLeft;
      offsets.y = offsetRect.y + offsetParent.clientTop;
    } else if (documentElement) {
      offsets.x = getWindowScrollBarX(documentElement);
    }
  }
  const htmlOffset = documentElement && !isOffsetParentAnElement && !isFixed ? getHTMLOffset(documentElement, scroll) : createCoords(0);
  const x = rect.left + scroll.scrollLeft - offsets.x - htmlOffset.x;
  const y = rect.top + scroll.scrollTop - offsets.y - htmlOffset.y;
  return {
    x,
    y,
    width: rect.width,
    height: rect.height
  };
}
function isStaticPositioned(element) {
  return getComputedStyle(element).position === "static";
}
function getTrueOffsetParent(element, polyfill) {
  if (!isHTMLElement(element) || getComputedStyle(element).position === "fixed") {
    return null;
  }
  if (polyfill) {
    return polyfill(element);
  }
  let rawOffsetParent = element.offsetParent;
  if (getDocumentElement(element) === rawOffsetParent) {
    rawOffsetParent = rawOffsetParent.ownerDocument.body;
  }
  return rawOffsetParent;
}
function getOffsetParent(element, polyfill) {
  const win = getWindow(element);
  if (isTopLayer(element)) {
    return win;
  }
  if (!isHTMLElement(element)) {
    let svgOffsetParent = getParentNode(element);
    while (svgOffsetParent && !isLastTraversableNode(svgOffsetParent)) {
      if (isElement(svgOffsetParent) && !isStaticPositioned(svgOffsetParent)) {
        return svgOffsetParent;
      }
      svgOffsetParent = getParentNode(svgOffsetParent);
    }
    return win;
  }
  let offsetParent = getTrueOffsetParent(element, polyfill);
  while (offsetParent && isTableElement(offsetParent) && isStaticPositioned(offsetParent)) {
    offsetParent = getTrueOffsetParent(offsetParent, polyfill);
  }
  if (offsetParent && isLastTraversableNode(offsetParent) && isStaticPositioned(offsetParent) && !isContainingBlock(offsetParent)) {
    return win;
  }
  return offsetParent || getContainingBlock(element) || win;
}
var getElementRects = async function(data) {
  const getOffsetParentFn = this.getOffsetParent || getOffsetParent;
  const getDimensionsFn = this.getDimensions;
  const floatingDimensions = await getDimensionsFn(data.floating);
  return {
    reference: getRectRelativeToOffsetParent(data.reference, await getOffsetParentFn(data.floating), data.strategy),
    floating: {
      x: 0,
      y: 0,
      width: floatingDimensions.width,
      height: floatingDimensions.height
    }
  };
};
function isRTL(element) {
  return getComputedStyle(element).direction === "rtl";
}
var platform = {
  convertOffsetParentRelativeRectToViewportRelativeRect,
  getDocumentElement,
  getClippingRect,
  getOffsetParent,
  getElementRects,
  getClientRects,
  getDimensions,
  getScale,
  isElement,
  isRTL
};
function observeMove(element, onMove) {
  let io = null;
  let timeoutId;
  const root = getDocumentElement(element);
  function cleanup() {
    var _io;
    clearTimeout(timeoutId);
    (_io = io) == null || _io.disconnect();
    io = null;
  }
  function refresh(skip, threshold) {
    if (skip === void 0) {
      skip = false;
    }
    if (threshold === void 0) {
      threshold = 1;
    }
    cleanup();
    const {
      left,
      top,
      width,
      height
    } = element.getBoundingClientRect();
    if (!skip) {
      onMove();
    }
    if (!width || !height) {
      return;
    }
    const insetTop = floor(top);
    const insetRight = floor(root.clientWidth - (left + width));
    const insetBottom = floor(root.clientHeight - (top + height));
    const insetLeft = floor(left);
    const rootMargin = -insetTop + "px " + -insetRight + "px " + -insetBottom + "px " + -insetLeft + "px";
    const options = {
      rootMargin,
      threshold: max(0, min(1, threshold)) || 1
    };
    let isFirstUpdate = true;
    function handleObserve(entries) {
      const ratio = entries[0].intersectionRatio;
      if (ratio !== threshold) {
        if (!isFirstUpdate) {
          return refresh();
        }
        if (!ratio) {
          timeoutId = setTimeout(() => {
            refresh(false, 1e-7);
          }, 1e3);
        } else {
          refresh(false, ratio);
        }
      }
      isFirstUpdate = false;
    }
    try {
      io = new IntersectionObserver(handleObserve, {
        ...options,
        // Handle <iframe>s
        root: root.ownerDocument
      });
    } catch (e) {
      io = new IntersectionObserver(handleObserve, options);
    }
    io.observe(element);
  }
  refresh(true);
  return cleanup;
}
function autoUpdate(reference, floating, update, options) {
  if (options === void 0) {
    options = {};
  }
  const {
    ancestorScroll = true,
    ancestorResize = true,
    elementResize = typeof ResizeObserver === "function",
    layoutShift = typeof IntersectionObserver === "function",
    animationFrame = false
  } = options;
  const referenceEl = unwrapElement(reference);
  const ancestors = ancestorScroll || ancestorResize ? [...referenceEl ? getOverflowAncestors(referenceEl) : [], ...getOverflowAncestors(floating)] : [];
  ancestors.forEach((ancestor) => {
    ancestorScroll && ancestor.addEventListener("scroll", update, {
      passive: true
    });
    ancestorResize && ancestor.addEventListener("resize", update);
  });
  const cleanupIo = referenceEl && layoutShift ? observeMove(referenceEl, update) : null;
  let reobserveFrame = -1;
  let resizeObserver = null;
  if (elementResize) {
    resizeObserver = new ResizeObserver((_ref) => {
      let [firstEntry] = _ref;
      if (firstEntry && firstEntry.target === referenceEl && resizeObserver) {
        resizeObserver.unobserve(floating);
        cancelAnimationFrame(reobserveFrame);
        reobserveFrame = requestAnimationFrame(() => {
          var _resizeObserver;
          (_resizeObserver = resizeObserver) == null || _resizeObserver.observe(floating);
        });
      }
      update();
    });
    if (referenceEl && !animationFrame) {
      resizeObserver.observe(referenceEl);
    }
    resizeObserver.observe(floating);
  }
  let frameId;
  let prevRefRect = animationFrame ? getBoundingClientRect(reference) : null;
  if (animationFrame) {
    frameLoop();
  }
  function frameLoop() {
    const nextRefRect = getBoundingClientRect(reference);
    if (prevRefRect && (nextRefRect.x !== prevRefRect.x || nextRefRect.y !== prevRefRect.y || nextRefRect.width !== prevRefRect.width || nextRefRect.height !== prevRefRect.height)) {
      update();
    }
    prevRefRect = nextRefRect;
    frameId = requestAnimationFrame(frameLoop);
  }
  update();
  return () => {
    var _resizeObserver2;
    ancestors.forEach((ancestor) => {
      ancestorScroll && ancestor.removeEventListener("scroll", update);
      ancestorResize && ancestor.removeEventListener("resize", update);
    });
    cleanupIo == null || cleanupIo();
    (_resizeObserver2 = resizeObserver) == null || _resizeObserver2.disconnect();
    resizeObserver = null;
    if (animationFrame) {
      cancelAnimationFrame(frameId);
    }
  };
}
var offset2 = offset;
var shift2 = shift;
var flip2 = flip;
var size2 = size;
var arrow2 = arrow;
var inline2 = inline;
var computePosition2 = (reference, floating, options) => {
  const cache = /* @__PURE__ */ new Map();
  const mergedOptions = {
    platform,
    ...options
  };
  const platformWithCache = {
    ...mergedOptions.platform,
    _c: cache
  };
  return computePosition(reference, floating, {
    ...mergedOptions,
    platform: platformWithCache
  });
};

// js/components/tooltip/position.js
var Position = class {
  constructor(parts) {
    this.parts = parts;
    this.cleanup = null;
  }
  setup(placement) {
    const updatePosition = () => {
      computePosition2(this.parts.trigger, this.parts.tooltip, {
        strategy: "fixed",
        placement,
        middleware: [inline2(), offset2(8), flip2(), shift2({ padding: 10 }), arrow2({ element: this.parts.arrow })]
      }).then(({ x, y, placement: placement2, middlewareData }) => {
        this._updateTooltipPosition(x, y);
        if (middlewareData.arrow) this._updateArrowPosition(placement2, middlewareData.arrow);
      });
    };
    updatePosition();
    this.cleanup = autoUpdate(this.parts.trigger, this.parts.tooltip, updatePosition);
  }
  _updateTooltipPosition(x, y) {
    Object.assign(this.parts.tooltip.style, {
      left: `${x}px`,
      top: `${y}px`
    });
  }
  _updateArrowPosition(placement, arrowData) {
    const { x: arrowX, y: arrowY } = arrowData;
    const staticSide = {
      top: "bottom",
      right: "left",
      bottom: "top",
      left: "right"
    }[placement.split("-")[0]];
    Object.assign(this.parts.arrow.style, {
      left: arrowX != null ? `${arrowX}px` : "",
      top: arrowY != null ? `${arrowY}px` : "",
      right: "",
      bottom: "",
      [staticSide]: "-2px"
    });
  }
  destroy() {
    this.cleanup?.();
  }
};

// js/components/tooltip/tooltip.js
var Tooltip = class _Tooltip {
  static PARTS = {
    trigger: { selector: ":first-child", required: true },
    tooltip: { selector: '[data-part="tooltip"]', required: true },
    arrow: { selector: '[data-part="arrow"]', required: false }
  };
  static CONFIG = {
    placement: {
      type: "enum",
      values: ["top", "bottom", "left", "right"],
      default: "top"
    },
    delay: {
      type: "number",
      default: 0
    },
    computed: {
      hasDelay: (config) => config.delay > 0
    }
  };
  #showTimeoutId = null;
  #boundMouseEnter;
  #boundMouseLeave;
  constructor(element) {
    if (!element) throw new Error("Element is required");
    this.parts = this.#initializeParts(element);
    this.config = new Config(element, _Tooltip.CONFIG);
    this.position = new Position(this.parts);
    this.animator = new Animator(this.parts.root);
    this.#boundMouseEnter = this.#handleMouseEnter.bind(this);
    this.#boundMouseLeave = this.#handleMouseLeave.bind(this);
    this.#bindEvents();
  }
  #initializeParts(root) {
    const parts = { root };
    Object.entries(_Tooltip.PARTS).forEach(([name, { selector, required }]) => {
      const part = root.querySelector(selector);
      if (required && !part) throw new Error(`Required tooltip part "${name}" not found`);
      parts[name] = part;
    });
    return Object.freeze(parts);
  }
  #bindEvents() {
    const { root } = this.parts;
    root.addEventListener("mouseenter", this.#boundMouseEnter);
    root.addEventListener("mouseleave", this.#boundMouseLeave);
  }
  #unbindEvents() {
    const { root } = this.parts;
    root.removeEventListener("mouseenter", this.#boundMouseEnter);
    root.removeEventListener("mouseleave", this.#boundMouseLeave);
  }
  #handleMouseEnter() {
    if (this.config.hasDelay) {
      this.#showTimeoutId = setTimeout(() => this.show(), this.config.delay);
    } else {
      this.show();
    }
  }
  #handleMouseLeave() {
    if (this.#showTimeoutId) {
      clearTimeout(this.#showTimeoutId);
      this.#showTimeoutId = null;
    }
    this.hide();
  }
  async show() {
    const { tooltip } = this.parts;
    this.position.setup(this.config.placement);
    tooltip.hidden = false;
    await this.animator.animateEnter(tooltip);
  }
  async hide() {
    const { tooltip } = this.parts;
    if (await this.animator.animateLeave(tooltip)) {
      tooltip.hidden = true;
      this.position.destroy();
    }
  }
  destroy() {
    this.#unbindEvents();
    this.position.destroy();
    if (this.#showTimeoutId) {
      clearTimeout(this.#showTimeoutId);
    }
  }
};

// js/hooks/tooltip.js
var tooltip_default = {
  mounted() {
    this.tooltip = new Tooltip(this.el);
  },
  updated() {
  },
  destroyed() {
    this.tooltip.destroy();
  },
  disconnected() {
  },
  reconnected() {
  }
};

// js/components/utils/mobile.js
var appleIphone = /iPhone/i;
var appleIpod = /iPod/i;
var appleTablet = /iPad/i;
var appleUniversal = /\biOS-universal(?:.+)Mac\b/i;
var androidPhone = /\bAndroid(?:.+)Mobile\b/i;
var androidTablet = /Android/i;
var amazonPhone = /(?:SD4930UR|\bSilk(?:.+)Mobile\b)/i;
var amazonTablet = /Silk/i;
var windowsPhone = /Windows Phone/i;
var windowsTablet = /\bWindows(?:.+)ARM\b/i;
var otherBlackBerry = /BlackBerry/i;
var otherBlackBerry10 = /BB10/i;
var otherOpera = /Opera Mini/i;
var otherChrome = /\b(CriOS|Chrome)(?:.+)Mobile/i;
var otherFirefox = /Mobile(?:.+)Firefox\b/i;
var isAppleTabletOnIos13 = (navigator2) => {
  return typeof navigator2 !== "undefined" && navigator2.platform === "MacIntel" && typeof navigator2.maxTouchPoints === "number" && navigator2.maxTouchPoints > 1 && typeof MSStream === "undefined";
};
function createMatch(userAgent) {
  return (regex) => regex.test(userAgent);
}
function isMobile(param) {
  let nav = {
    userAgent: "",
    platform: "",
    maxTouchPoints: 0
  };
  if (!param && typeof navigator !== "undefined") {
    nav = {
      userAgent: navigator.userAgent,
      platform: navigator.platform,
      maxTouchPoints: navigator.maxTouchPoints || 0
    };
  } else if (typeof param === "string") {
    nav.userAgent = param;
  } else if (param && param.userAgent) {
    nav = {
      userAgent: param.userAgent,
      platform: param.platform,
      maxTouchPoints: param.maxTouchPoints || 0
    };
  }
  let userAgent = nav.userAgent;
  let tmp = userAgent.split("[FBAN");
  if (typeof tmp[1] !== "undefined") {
    userAgent = tmp[0];
  }
  tmp = userAgent.split("Twitter");
  if (typeof tmp[1] !== "undefined") {
    userAgent = tmp[0];
  }
  const match = createMatch(userAgent);
  const result = {
    apple: {
      phone: match(appleIphone) && !match(windowsPhone),
      ipod: match(appleIpod),
      tablet: !match(appleIphone) && (match(appleTablet) || isAppleTabletOnIos13(nav)) && !match(windowsPhone),
      universal: match(appleUniversal),
      device: (match(appleIphone) || match(appleIpod) || match(appleTablet) || match(appleUniversal) || isAppleTabletOnIos13(nav)) && !match(windowsPhone)
    },
    amazon: {
      phone: match(amazonPhone),
      tablet: !match(amazonPhone) && match(amazonTablet),
      device: match(amazonPhone) || match(amazonTablet)
    },
    android: {
      phone: !match(windowsPhone) && match(amazonPhone) || !match(windowsPhone) && match(androidPhone),
      tablet: !match(windowsPhone) && !match(amazonPhone) && !match(androidPhone) && (match(amazonTablet) || match(androidTablet)),
      device: !match(windowsPhone) && (match(amazonPhone) || match(amazonTablet) || match(androidPhone) || match(androidTablet)) || match(/\bokhttp\b/i)
    },
    windows: {
      phone: match(windowsPhone),
      tablet: match(windowsTablet),
      device: match(windowsPhone) || match(windowsTablet)
    },
    other: {
      blackberry: match(otherBlackBerry),
      blackberry10: match(otherBlackBerry10),
      opera: match(otherOpera),
      firefox: match(otherFirefox),
      chrome: match(otherChrome),
      device: match(otherBlackBerry) || match(otherBlackBerry10) || match(otherOpera) || match(otherFirefox) || match(otherChrome)
    },
    any: false,
    phone: false,
    tablet: false
  };
  result.any = result.apple.device || result.android.device || result.windows.device || result.other.device;
  result.phone = result.apple.phone || result.android.phone || result.windows.phone;
  result.tablet = result.apple.tablet || result.android.tablet || result.windows.tablet;
  return result;
}

// js/components/popover/popover.js
var Popover = class _Popover {
  static PARTS = {
    trigger: { selector: ":first-child", required: false },
    popover: { selector: '[data-part="popover"]', required: true }
  };
  static CONFIG = {
    placement: {
      type: "enum",
      values: [
        "top",
        "bottom",
        "left",
        "right",
        "top-start",
        "bottom-start",
        "left-start",
        "right-start",
        "top-end",
        "bottom-end",
        "left-end",
        "right-end"
      ],
      default: "top"
    },
    target: {
      type: "string",
      default: null
    },
    openOnHover: {
      type: "boolean",
      default: false
    },
    openOnFocus: {
      type: "boolean",
      default: false
    },
    computed: {
      shouldHandleHover: (config) => config.openOnHover && !isMobile(window.navigator).any && !config.target
    }
  };
  // State management
  #states = {
    CLOSED: "closed",
    OPENING: "opening",
    OPEN: "open",
    CLOSING: "closing"
  };
  #state = this.#states.CLOSED;
  // Core properties
  #hoverIntent = null;
  #parts;
  #config;
  #animator;
  #controller = new AbortController();
  // Positioning
  #referenceElement;
  #positionCleanup = null;
  constructor(element) {
    if (!element) throw new Error("Element is required");
    this.#parts = this.#initializeParts(element);
    this.#config = new Config(element, _Popover.CONFIG);
    this.#referenceElement = this.#config.target ? document.querySelector(this.#config.target) : this.#parts.trigger;
    if (!this.#referenceElement) {
      const targetInfo = this.#config.target ? `target "${this.#config.target}"` : "trigger element";
      throw new Error(`Popover ${targetInfo} not found`);
    }
    this.#animator = new Animator(this.#parts.root);
    this.#parts.root.setAttribute("aria-expanded", "false");
    this.#parts.root.setAttribute("data-open", "false");
    this.#bindEvents();
    this.#bindCustomEvents();
  }
  #initializeParts(root) {
    const parts = { root };
    Object.entries(_Popover.PARTS).forEach(([name, { selector, required }]) => {
      const part = root.querySelector(selector);
      if (required && !part) throw new Error(`Required popover part "${name}" not found`);
      parts[name] = part;
    });
    return Object.freeze(parts);
  }
  #bindEvents() {
    const { root, popover, trigger } = this.#parts;
    const { signal } = this.#controller;
    if (trigger && !this.#config.target) {
      if (this.#config.openOnFocus) {
        root.addEventListener("focusin", this.#handleFocusIn, { signal });
        root.addEventListener("focusout", this.#handleFocusOut, { signal });
      } else {
        root.addEventListener("click", this.#handleRootClick, { signal });
      }
      if (this.#config.shouldHandleHover) {
        root.addEventListener("mouseenter", this.#handleMouseEnter, { signal });
        root.addEventListener("mouseleave", this.#handleMouseLeave, { signal });
        popover.addEventListener("mouseenter", this.#handlePopoverMouseEnter, { signal });
        popover.addEventListener("mouseleave", this.#handlePopoverMouseLeave, { signal });
      }
    }
  }
  #bindCustomEvents() {
    const { signal } = this.#controller;
    window.addEventListener("fluxon:popover:open", this.#handleCustomOpen, { signal });
    window.addEventListener("fluxon:popover:close", this.#handleCustomClose, { signal });
  }
  #unbindEvents() {
    this.#controller.abort();
  }
  async #updateOpenState(targetState) {
    const newState = targetState ? this.#states.OPEN : this.#states.CLOSED;
    if (this.#state === newState) return;
    const { root, popover } = this.#parts;
    const { signal } = this.#controller;
    root.setAttribute("aria-expanded", String(targetState));
    root.setAttribute("data-open", String(targetState));
    if (targetState) {
      this.#state = this.#states.OPENING;
      this.#setupPositioning();
      popover.hidden = false;
      await this.#animator.animateEnter(popover);
      document.addEventListener("keydown", this.#handleKeyDown, { signal });
      document.addEventListener("click", this.#handleOutsideClick, { signal });
      this.#state = this.#states.OPEN;
    } else {
      if (popover.contains(document.activeElement)) {
        document.activeElement.blur();
      }
      this.#state = this.#states.CLOSING;
      if (await this.#animator.animateLeave(popover)) {
        popover.hidden = true;
        this.#destroyPositioning();
        this.#state = this.#states.CLOSED;
      }
    }
  }
  #handleRootClick = (event2) => {
    if (!this.#parts.popover.contains(event2.target)) {
      const shouldOpen = this.#state === this.#states.CLOSED;
      this.#updateOpenState(shouldOpen);
    }
  };
  #handleOutsideClick = (event2) => {
    if (!this.#parts.root.contains(event2.target)) {
      this.#updateOpenState(false);
    }
  };
  #handleKeyDown = (event2) => {
    if (event2.key === "Escape" && !this.#config.openOnFocus) {
      event2.preventDefault();
      event2.stopPropagation();
      this.#updateOpenState(false);
    }
  };
  #handleFocusIn = () => {
    if (this.#state === this.#states.CLOSED) this.#updateOpenState(true);
  };
  #handleFocusOut = (event2) => {
    if (this.#state === this.#states.OPEN && !this.#parts.root.contains(event2.relatedTarget)) {
      this.#updateOpenState(false);
    }
  };
  #handleMouseEnter = () => {
    if (this.#state === this.#states.CLOSED) this.#updateOpenState(true);
  };
  #handleMouseLeave = (event2) => {
    if (this.#state === this.#states.OPEN) {
      this.#hoverIntent = setTimeout(() => {
        if (!this.#isMouseOverPopover(event2)) {
          this.#updateOpenState(false);
        }
      }, 100);
    }
  };
  #handlePopoverMouseEnter = () => {
    if (this.#hoverIntent) {
      clearTimeout(this.#hoverIntent);
      this.#hoverIntent = null;
    }
  };
  #handlePopoverMouseLeave = () => {
    if (this.#state === this.#states.OPEN) this.#updateOpenState(false);
  };
  #setupPositioning() {
    const updatePosition = () => {
      computePosition2(this.#referenceElement, this.#parts.popover, {
        strategy: "fixed",
        placement: this.#config.placement,
        middleware: [inline2(), offset2(8), flip2(), shift2({ padding: 20 })]
      }).then(({ x, y }) => {
        Object.assign(this.#parts.popover.style, {
          left: `${x}px`,
          top: `${y}px`
        });
      });
    };
    updatePosition();
    this.#positionCleanup = autoUpdate(this.#referenceElement, this.#parts.popover, updatePosition);
  }
  #destroyPositioning() {
    this.#positionCleanup?.();
    this.#positionCleanup = null;
  }
  #isMouseOverPopover = (event2) => {
    if (!event2 || typeof event2.clientX !== "number" || typeof event2.clientY !== "number") {
      return false;
    }
    const rect = this.#parts.popover.getBoundingClientRect();
    const { clientX, clientY } = event2;
    return clientX >= rect.left && clientX <= rect.right && clientY >= rect.top && clientY <= rect.bottom;
  };
  #handleCustomOpen = (event2) => {
    if (event2.target === this.#parts.root) {
      this.open();
    }
  };
  #handleCustomClose = (event2) => {
    if (event2.target === this.#parts.root) {
      this.close();
    }
  };
  get config() {
    return this.#config;
  }
  get isOpen() {
    return this.#state === this.#states.OPEN;
  }
  get state() {
    return this.#state;
  }
  open() {
    return this.#updateOpenState(true);
  }
  close() {
    return this.#updateOpenState(false);
  }
  destroy() {
    this.#unbindEvents();
    this.#destroyPositioning();
    if (this.#hoverIntent) {
      clearTimeout(this.#hoverIntent);
      this.#hoverIntent = null;
    }
  }
};

// js/hooks/popover.js
var popover_default = {
  mounted() {
    this.popover = new Popover(this.el);
  },
  updated() {
  },
  destroyed() {
    this.popover.destroy();
  },
  disconnected() {
  },
  reconnected() {
  }
};

// js/components/tabs/tabs.js
var Tabs = class _Tabs {
  static PARTS = {
    tablist: { selector: '[data-part="tablist"]', required: true },
    tabs: {
      root: "tablist",
      selector: '[data-part="tab"]',
      required: true,
      multiple: true
    },
    panels: {
      selector: '[data-part="tabpanel"]',
      required: false,
      multiple: true
    }
  };
  // static CONFIG = {}
  #activeIndex;
  #focusedIndex;
  #boundHandlers;
  #parts;
  constructor(element) {
    if (!element) throw new Error("Element is required");
    this.#parts = this.#initializeParts(element);
    this.#activeIndex = this.#parts.tabs.findIndex((tab) => tab.getAttribute("aria-selected") === "true") || 0;
    this.#focusedIndex = null;
    this.#boundHandlers = /* @__PURE__ */ new Map();
    this.#setupTabs();
    this.#bindEvents();
  }
  #initializeParts = (root) => {
    const parts = { root };
    for (const [name, { selector, required, multiple, root: partRoot }] of Object.entries(_Tabs.PARTS)) {
      const searchRoot = partRoot ? parts[partRoot] : root;
      const elements = multiple ? searchRoot.querySelectorAll(selector) : searchRoot.querySelector(selector);
      if (required && (!elements || multiple && elements.length === 0)) {
        throw new Error(`Required tabs part "${name}" not found`);
      }
      parts[name] = multiple ? Array.from(elements) : elements;
    }
    return Object.freeze(parts);
  };
  #setupTabs = () => {
    const { tabs, panels } = this.#parts;
    const panelsById = new Map(panels.map((panel) => [panel.id, panel]));
    tabs.forEach((tab) => {
      const panelId = tab.dataset.panel;
      const panel = panelsById.get(panelId);
      if (panel) {
        tab.setAttribute("aria-controls", panelId);
        panel.setAttribute("aria-labelledby", tab.id);
      }
    });
  };
  #bindEvents = () => {
    this.#parts.tabs.forEach((tab, index) => {
      const clickHandler = (e) => {
        e.preventDefault();
        this.#updateActiveTab(index);
      };
      const keydownHandler = (e) => {
        if (["ArrowRight", "ArrowLeft", "ArrowDown", "ArrowUp", "Home", "End"].includes(e.key)) {
          e.preventDefault();
          this.#handleKeyNavigation(e.key);
        }
      };
      const focusHandler = () => {
        this.#focusedIndex = index;
        this.#updateFocusedTab(index);
      };
      tab.addEventListener("click", clickHandler);
      tab.addEventListener("keydown", keydownHandler);
      tab.addEventListener("focus", focusHandler);
      this.#boundHandlers.set(tab, { clickHandler, keydownHandler, focusHandler });
    });
  };
  #handleKeyNavigation = (key) => {
    const { tabs } = this.#parts;
    const currentIndex = this.#focusedIndex !== null ? this.#focusedIndex : this.#activeIndex;
    let newIndex = currentIndex;
    switch (key) {
      case "ArrowRight":
      case "ArrowDown":
        newIndex = (currentIndex + 1) % tabs.length;
        break;
      case "ArrowLeft":
      case "ArrowUp":
        newIndex = (currentIndex - 1 + tabs.length) % tabs.length;
        break;
      case "Home":
        newIndex = 0;
        break;
      case "End":
        newIndex = tabs.length - 1;
        break;
    }
    if (newIndex !== currentIndex) {
      this.#updateActiveTab(newIndex);
    }
  };
  #updateActiveTab = (newIndex) => {
    const { tabs } = this.#parts;
    const oldIndex = this.#activeIndex;
    if (tabs[oldIndex]) {
      tabs[oldIndex].removeAttribute("data-active");
      tabs[oldIndex].setAttribute("aria-selected", "false");
      tabs[oldIndex].setAttribute("tabindex", "-1");
      const oldPanelId = tabs[oldIndex].dataset.panel;
      if (oldPanelId) {
        const oldPanel = document.getElementById(oldPanelId);
        if (oldPanel) {
          if (oldPanel.contains(document.activeElement)) {
            document.activeElement.blur();
          }
          oldPanel.hidden = true;
          oldPanel.setAttribute("aria-hidden", "true");
        }
      }
    }
    tabs[newIndex].setAttribute("data-active", "");
    tabs[newIndex].setAttribute("aria-selected", "true");
    tabs[newIndex].setAttribute("tabindex", "0");
    const newPanelId = tabs[newIndex].dataset.panel;
    if (newPanelId) {
      const newPanel = document.getElementById(newPanelId);
      if (newPanel) {
        newPanel.hidden = false;
        newPanel.setAttribute("aria-hidden", "false");
      }
    }
    if (tabs[newIndex].tagName.toLowerCase() === "a") {
      tabs[newIndex].click();
    }
    this.#activeIndex = newIndex;
    this.#focusTab(newIndex);
  };
  #updateFocusedTab = (newIndex) => {
    const { tabs } = this.#parts;
    if (this.#focusedIndex !== null && this.#focusedIndex !== newIndex) {
      tabs[this.#focusedIndex].tabIndex = -1;
    }
    tabs[newIndex].tabIndex = 0;
  };
  #focusTab = (index) => {
    this.#parts.tabs[index].focus();
  };
  destroy() {
    this.#parts.tabs.forEach((tab) => {
      const handlers = this.#boundHandlers.get(tab);
      if (handlers) {
        tab.removeEventListener("click", handlers.clickHandler);
        tab.removeEventListener("keydown", handlers.keydownHandler);
        tab.removeEventListener("focus", handlers.focusHandler);
      }
    });
    this.#boundHandlers.clear();
  }
};

// js/hooks/tabs.js
var tabs_default = {
  mounted() {
    this.tabs = new Tabs(this.el);
  },
  updated() {
  },
  destroyed() {
    this.tabs.destroy();
  },
  disconnected() {
  },
  reconnected() {
  }
};

// js/components/dropdown/position.js
var Position2 = class {
  constructor(parts) {
    this.parts = parts;
    this.cleanup = null;
  }
  setup(placement) {
    const updatePosition = () => {
      computePosition2(this.parts.button, this.parts.menu, {
        strategy: "fixed",
        placement,
        middleware: [
          offset2(this.parts.root.dataset.offset || 5),
          flip2({
            fallbackStrategy: "bestFit",
            fallbackAxisSideDirection: "end",
            crossAxis: false
          }),
          shift2({ padding: 10 }),
          size2({
            apply({ elements, rects, placement: placement2 }) {
              const viewportHeight = window.innerHeight;
              const buttonRect = rects.reference;
              const minHeight = 200;
              const maxHeight = 500;
              let availableSpace;
              if (placement2.startsWith("top")) {
                availableSpace = buttonRect.top;
              } else {
                availableSpace = viewportHeight - buttonRect.bottom;
              }
              const appliedMaxHeight = Math.min(maxHeight, availableSpace - 10);
              if (appliedMaxHeight < minHeight) return;
              elements.floating.style.maxHeight = `${appliedMaxHeight}px`;
            }
          })
        ]
      }).then(({ x, y }) => {
        Object.assign(this.parts.menu.style, {
          left: `${x}px`,
          top: `${y}px`
        });
      });
    };
    this.cleanup = autoUpdate(this.parts.button, this.parts.menu, updatePosition);
  }
  destroy() {
    if (this.cleanup) {
      this.cleanup();
      this.cleanup = null;
    }
  }
};

// js/components/dropdown/dropdown.js
var Dropdown = class _Dropdown {
  static PARTS = {
    button: { selector: '[data-part="button"]', required: true },
    menu: { selector: '[data-part="menu"]', required: true },
    menuItems: { selector: '[data-part="menuitem"]', required: false, multiple: true }
  };
  static CONFIG = {
    placement: {
      type: "enum",
      values: [
        "top",
        "bottom",
        "left",
        "right",
        "top-start",
        "bottom-start",
        "left-start",
        "right-start",
        "top-end",
        "bottom-end",
        "left-end",
        "right-end"
      ],
      default: "bottom-start"
    },
    openOnHover: {
      type: "boolean",
      default: false
    },
    hoverOpenDelay: {
      type: "number",
      default: 200
    },
    hoverCloseDelay: {
      type: "number",
      default: 200
    }
  };
  // Private fields declaration
  #isOpen = false;
  #selectedIndex = null;
  #hoverTimeout = null;
  #parts;
  #config;
  #position;
  #animator;
  #isMouseMode = false;
  // Track whether we're in mouse or keyboard navigation mode
  constructor(element) {
    if (!element) throw new Error("Element is required");
    this.#parts = this.#initializeParts(element);
    this.#config = new Config(element, _Dropdown.CONFIG);
    this.#position = new Position2(this.#parts);
    this.#animator = new Animator(element);
    this.#setupMenu();
    this.#bindEvents();
  }
  #initializeParts(root) {
    const parts = { root };
    Object.entries(_Dropdown.PARTS).forEach(([name, { selector, required, multiple }]) => {
      const elements = root.querySelectorAll(selector);
      if (required && (!elements || multiple && elements.length === 0)) {
        throw new Error(`Required dropdown part "${name}" not found`);
      }
      parts[name] = multiple ? Array.from(elements) : elements[0];
    });
    return Object.freeze(parts);
  }
  #setupMenu() {
    const { menuItems } = this.#parts;
    if (menuItems?.length) {
      menuItems.forEach((item) => {
        item.setAttribute("tabindex", "-1");
        item.setAttribute("role", "menuitem");
      });
    }
  }
  #bindEvents() {
    const { root, button, menu } = this.#parts;
    button.addEventListener("click", this.#handleClick);
    root.addEventListener("keydown", this.#handleKeyDown);
    menu.addEventListener("mouseover", this.#handleMenuMouseOver);
    menu.addEventListener("mouseleave", this.#handleMenuMouseLeave);
    menu.addEventListener("click", this.#handleMenuClick);
    document.addEventListener("click", this.#handleOutsideClick);
    if (this.#config.openOnHover) {
      button.addEventListener("mouseenter", this.#handleHoverEnter);
      button.addEventListener("mouseleave", this.#handleHoverLeave);
      menu.addEventListener("mouseenter", this.#handleHoverEnter);
      menu.addEventListener("mouseleave", this.#handleHoverLeave);
    }
  }
  async #updateOpenState(isOpen) {
    if (this.#isOpen === isOpen) return;
    const { button, menu } = this.#parts;
    button.setAttribute("aria-expanded", String(isOpen));
    this.#isOpen = isOpen;
    if (isOpen) {
      this.#position.setup(this.#config.placement);
      menu.hidden = false;
      await this.#animator.animateEnter(menu);
    } else {
      if (await this.#animator.animateLeave(menu)) {
        menu.hidden = true;
        this.#position.destroy();
        this.#updateSelectedItem(null);
      }
    }
  }
  #isItemDisabled(item) {
    return item.hasAttribute("disabled") || item.hasAttribute("data-disabled") || item.getAttribute("aria-disabled") === "true";
  }
  #updateSelectedItem(index, fromMouse = false) {
    const { menuItems, menu } = this.#parts;
    const oldIndex = this.#selectedIndex;
    if (oldIndex !== null && menuItems?.[oldIndex]) {
      menuItems[oldIndex].removeAttribute("data-highlighted");
    }
    this.#isMouseMode = fromMouse;
    if (index !== null && menuItems?.[index] && !this.#isItemDisabled(menuItems[index])) {
      menuItems[index].setAttribute("data-highlighted", "true");
      if (!fromMouse) {
        menuItems[index].scrollIntoView({ block: "nearest" });
      }
      menu.setAttribute("aria-activedescendant", menuItems[index].id || "");
    } else {
      menu.removeAttribute("aria-activedescendant");
    }
    this.#selectedIndex = index;
  }
  // Event Handlers
  #handleClick = (event2) => {
    event2.preventDefault();
    this.#updateOpenState(!this.#isOpen);
  };
  #handleKeyDown = (event2) => {
    switch (event2.key) {
      case "ArrowUp":
        event2.preventDefault();
        this.#handleArrowNavigation("up");
        break;
      case "ArrowDown":
        event2.preventDefault();
        this.#handleArrowNavigation("down");
        break;
      case "Enter":
      case " ":
        if (this.#isOpen && this.#selectedIndex !== null) {
          this.#handleEnterOrSpace();
        }
        break;
      case "Escape":
        event2.preventDefault();
        this.#updateOpenState(false);
        this.#parts.button.focus();
        break;
      case "Tab":
        if (this.#isOpen) {
          this.#updateOpenState(false);
        }
        break;
    }
  };
  #handleArrowNavigation(direction) {
    const { menuItems } = this.#parts;
    if (!menuItems?.length) return;
    if (!this.#isOpen) {
      this.#updateOpenState(true);
      const defaultIndex = this.#getFirstOrLastEnabledIndex(direction === "up");
      this.#updateSelectedItem(defaultIndex);
      return;
    }
    if (this.#selectedIndex === null) {
      const defaultIndex = this.#getFirstOrLastEnabledIndex(direction === "up");
      this.#updateSelectedItem(defaultIndex);
      return;
    }
    const nextIndex = this.#findNextEnabledItem(this.#selectedIndex, direction);
    if (nextIndex !== null) {
      this.#updateSelectedItem(nextIndex);
    }
  }
  #findNextEnabledItem(startIndex, direction) {
    const { menuItems } = this.#parts;
    if (!menuItems?.length) return null;
    const increment = direction === "up" ? -1 : 1;
    let currentIndex = startIndex + increment;
    while (currentIndex >= 0 && currentIndex < menuItems.length) {
      if (!this.#isItemDisabled(menuItems[currentIndex])) {
        return currentIndex;
      }
      currentIndex += increment;
    }
    return null;
  }
  #getFirstOrLastEnabledIndex(getLast = false) {
    const { menuItems } = this.#parts;
    if (getLast) {
      for (let i = menuItems.length - 1; i >= 0; i--) {
        if (!this.#isItemDisabled(menuItems[i])) {
          return i;
        }
      }
    } else {
      for (let i = 0; i < menuItems.length; i++) {
        if (!this.#isItemDisabled(menuItems[i])) {
          return i;
        }
      }
    }
    return null;
  }
  #handleEnterOrSpace() {
    if (this.#selectedIndex !== null && this.#parts.menuItems?.[this.#selectedIndex] && !this.#isItemDisabled(this.#parts.menuItems[this.#selectedIndex])) {
      this.#triggerItemAction(this.#selectedIndex);
    }
    this.#updateOpenState(false);
    this.#parts.button.focus();
  }
  #handleOutsideClick = (event2) => {
    if (!this.#isOpen) return;
    const { root } = this.#parts;
    const clickedElement = event2.target;
    if (!root.contains(clickedElement)) {
      this.#updateOpenState(false);
    }
  };
  #handleHoverEnter = () => {
    clearTimeout(this.#hoverTimeout);
    if (!this.#isOpen) {
      this.#hoverTimeout = setTimeout(() => {
        this.#updateOpenState(true);
      }, this.#config.hoverOpenDelay);
    }
  };
  #handleHoverLeave = () => {
    clearTimeout(this.#hoverTimeout);
    this.#hoverTimeout = setTimeout(() => {
      this.#updateOpenState(false);
    }, this.#config.hoverCloseDelay);
  };
  #handleMenuMouseOver = (event2) => {
    const menuItem = event2.target.closest('[data-part="menuitem"]');
    if (menuItem && !this.#isItemDisabled(menuItem)) {
      const index = this.#parts.menuItems.indexOf(menuItem);
      if (index !== -1) {
        this.#updateSelectedItem(index, true);
      }
    }
  };
  #handleMenuMouseLeave = (event2) => {
    if (this.#isMouseMode && !event2.relatedTarget?.closest('[data-part="menu"]')) {
      this.#updateSelectedItem(null, true);
    }
  };
  #handleMenuClick = (event2) => {
    const menuItem = event2.target.closest('[data-part="menuitem"]');
    if (menuItem && !this.#isItemDisabled(menuItem)) {
      setTimeout(() => {
        this.#updateOpenState(false);
      }, 10);
    }
  };
  #triggerItemAction(index) {
    const item = this.#parts.menuItems?.[index];
    if (item && !this.#isItemDisabled(item)) {
      item.tagName === "A" ? window.location.href = item.href : item.click();
    }
  }
  reload() {
    this.#parts = this.#initializeParts(this.#parts.root);
  }
  destroy() {
    const { root, button, menu } = this.#parts;
    button.removeEventListener("click", this.#handleClick);
    root.removeEventListener("keydown", this.#handleKeyDown);
    menu.removeEventListener("mouseover", this.#handleMenuMouseOver);
    menu.removeEventListener("mouseleave", this.#handleMenuMouseLeave);
    menu.removeEventListener("click", this.#handleMenuClick);
    document.removeEventListener("click", this.#handleOutsideClick);
    if (this.#config.openOnHover) {
      button.removeEventListener("mouseenter", this.#handleHoverEnter);
      button.removeEventListener("mouseleave", this.#handleHoverLeave);
      menu.removeEventListener("mouseenter", this.#handleHoverEnter);
      menu.removeEventListener("mouseleave", this.#handleHoverLeave);
    }
    clearTimeout(this.#hoverTimeout);
    this.#position.destroy();
  }
};

// js/hooks/dropdown.js
var dropdown_default = {
  mounted() {
    this.dropdown = new Dropdown(this.el);
  },
  updated() {
    this.dropdown.reload();
  },
  destroyed() {
    this.dropdown.destroy();
  },
  disconnected() {
  },
  reconnected() {
  }
};

// js/components/utils/focus-trap.js
var FocusTrap = class _FocusTrap {
  // Selector for potentially focusable elements
  static FOCUSABLE_SELECTOR = [
    'a[href]:not([rel="ignore"])',
    "area[href]",
    "input:not([disabled])",
    "select:not([disabled])",
    "textarea:not([disabled])",
    "button:not([disabled])",
    "iframe",
    '[tabindex]:not([tabindex="-1"]):not([aria-hidden="true"])'
  ].join(",");
  constructor(element, options) {
    if (!options?.content) {
      throw new Error("Content element is required in options");
    }
    this.el = element;
    this.focusStart = element.firstElementChild;
    this.focusEnd = element.lastElementChild;
    this.content = options.content;
    if (!this.focusStart || !this.focusEnd) {
      throw new Error(`Focus trap elements not found. Make sure to include elements in the #${element.id}`);
    }
  }
  activate() {
    this.focusStart.addEventListener("focus", () => this.focusLast());
    this.focusEnd.addEventListener("focus", () => this.focusFirst());
    if (this.content && !this.hasAnyFocusableElements(this.content)) {
      this.content.tabIndex = 0;
      this.content.setAttribute("role", "region");
    }
    if (window.getComputedStyle(this.el).display !== "none") {
      this.focusInitialElement();
    }
  }
  focusInitialElement() {
    const autofocusElement = this.content.querySelector("[autofocus]");
    if (autofocusElement && this.attemptFocus(autofocusElement)) {
      return true;
    }
    return this.focusFirst();
  }
  deactivate() {
    this.focusStart.removeEventListener("focus", () => this.focusLast());
    this.focusEnd.removeEventListener("focus", () => this.focusFirst());
    if (this.content && this.content.getAttribute("tabindex") === "0") {
      this.content.removeAttribute("tabindex");
      this.content.removeAttribute("role");
    }
  }
  hasAnyFocusableElements(element) {
    const focusableElements = element.querySelectorAll(_FocusTrap.FOCUSABLE_SELECTOR);
    return focusableElements.length > 0;
  }
  isFocusable(element) {
    return element.matches?.(_FocusTrap.FOCUSABLE_SELECTOR) ?? false;
  }
  attemptFocus(element) {
    if (this.isFocusable(element)) {
      try {
        element.focus({ preventScroll: true });
      } catch (e) {
      }
    }
    return document.activeElement?.isSameNode(element) ?? false;
  }
  focusFirst() {
    return this.focusFirstElement(this.el);
  }
  focusLast() {
    return this.focusLastElement(this.el);
  }
  focusFirstElement(element) {
    let child = element.firstElementChild;
    while (child) {
      if (this.attemptFocus(child) || this.focusFirstElement(child)) {
        return true;
      }
      child = child.nextElementSibling;
    }
    return false;
  }
  focusLastElement(element) {
    let child = element.lastElementChild;
    while (child) {
      if (this.attemptFocus(child) || this.focusLastElement(child)) {
        return true;
      }
      child = child.previousElementSibling;
    }
    return false;
  }
};

// js/components/utils/scrollbar-helper.js
var ScrollbarHelper = class _ScrollbarHelper {
  static #instance = null;
  #element;
  #originalPadding = null;
  #originalOverflow = null;
  #referenceCount = 0;
  constructor() {
    if (_ScrollbarHelper.#instance) return _ScrollbarHelper.#instance;
    _ScrollbarHelper.#instance = this;
    this.#element = document.body;
  }
  hasScrollbarGutterStable() {
    const htmlElement = document.documentElement;
    const computedStyle = window.getComputedStyle(htmlElement);
    return computedStyle.scrollbarGutter === "stable";
  }
  getWidth() {
    const documentWidth = document.documentElement.clientWidth;
    return Math.abs(window.innerWidth - documentWidth);
  }
  hide() {
    this.#referenceCount++;
    if (this.#referenceCount > 1) {
      return;
    }
    if (this.hasScrollbarGutterStable()) {
      this.#originalOverflow = this.#element.style.overflow;
      this.#element.style.overflow = "hidden";
      return;
    }
    const scrollbarWidth = this.getWidth();
    if (scrollbarWidth === 0) {
      this.#originalOverflow = this.#element.style.overflow;
      this.#element.style.overflow = "hidden";
      return;
    }
    this.#originalPadding = this.#element.style.paddingRight;
    this.#originalOverflow = this.#element.style.overflow;
    const currentPadding = parseFloat(window.getComputedStyle(this.#element).paddingRight);
    this.#element.style.paddingRight = `${currentPadding + scrollbarWidth}px`;
    this.#element.style.overflow = "hidden";
  }
  reset() {
    this.#referenceCount = Math.max(0, this.#referenceCount - 1);
    if (this.#referenceCount > 0) {
      return;
    }
    if (this.#originalPadding !== null) {
      this.#element.style.paddingRight = this.#originalPadding;
    }
    if (this.#originalOverflow !== null) {
      this.#element.style.overflow = this.#originalOverflow;
    }
    this.#originalPadding = null;
    this.#originalOverflow = null;
  }
  // Force reset the helper state (useful for testing or error recovery)
  forceReset() {
    this.#referenceCount = 0;
    if (this.#originalPadding !== null) {
      this.#element.style.paddingRight = this.#originalPadding;
    }
    if (this.#originalOverflow !== null) {
      this.#element.style.overflow = this.#originalOverflow;
    }
    this.#originalPadding = null;
    this.#originalOverflow = null;
  }
};

// js/components/dialog/stacker.js
var Stacker = class _Stacker {
  static #instance = null;
  #dialogs = [];
  #scrollbarHelper;
  #isScrollbarHidden = false;
  constructor() {
    if (_Stacker.#instance) return _Stacker.#instance;
    _Stacker.#instance = this;
    this.#scrollbarHelper = new ScrollbarHelper();
    document.addEventListener("keydown", this.#handleEscape.bind(this));
  }
  addDialog(dialog) {
    if (!this.#dialogs.includes(dialog)) {
      this.#dialogs.push(dialog);
      this.#refreshDialogStates();
    }
  }
  removeDialog(dialog) {
    this.#dialogs = this.#dialogs.filter((d) => d !== dialog);
    dialog.updateState(DialogStates.HIDDEN);
    this.#refreshDialogStates();
  }
  #handleEscape = (event2) => {
    if (event2.key === "Escape") {
      this.#activeDialog()?.handleEscape();
    }
  };
  // Returns the topmost dialog (last in array).
  #activeDialog = () => this.#dialogs.at(-1);
  #refreshDialogStates = () => {
    const activeDialog = this.#activeDialog();
    this.#dialogs.forEach((dialog, index) => {
      const state = dialog === activeDialog ? DialogStates.FOREGROUND : DialogStates.BACKGROUND;
      dialog.updateState(state);
      dialog.updateStackPosition(index);
    });
    const shouldHideScrollbar = this.#dialogs.length > 0;
    if (shouldHideScrollbar && !this.#isScrollbarHidden) {
      this.#scrollbarHelper.hide();
      this.#isScrollbarHidden = true;
    } else if (!shouldHideScrollbar && this.#isScrollbarHidden) {
      this.#scrollbarHelper.reset();
      this.#isScrollbarHidden = false;
    }
  };
};

// js/components/utils/attr-observer.js
var AttrObserver = class {
  constructor(element) {
    if (!element) throw new Error("Element is required");
    this.element = element;
    this.observer = null;
    this.handlers = /* @__PURE__ */ new Map();
  }
  watch(attribute, callback) {
    if (!this.handlers.has(attribute)) {
      this.handlers.set(attribute, /* @__PURE__ */ new Set());
    }
    this.handlers.get(attribute).add(callback);
    this._setupObserver();
    return this;
  }
  unwatch(attribute, callback) {
    const callbacks = this.handlers.get(attribute);
    if (callbacks) {
      callbacks.delete(callback);
      if (callbacks.size === 0) {
        this.handlers.delete(attribute);
      }
    }
    if (this.handlers.size === 0) {
      this._teardownObserver();
    } else {
      this._setupObserver();
    }
    return this;
  }
  _setupObserver() {
    if (this.observer) {
      this.observer.disconnect();
    }
    this.observer = new MutationObserver(this._handleMutations.bind(this));
    this.observer.observe(this.element, {
      attributes: true,
      attributeFilter: Array.from(this.handlers.keys())
    });
  }
  _handleMutations(mutations) {
    for (const mutation of mutations) {
      if (mutation.type === "attributes" && mutation.attributeName) {
        const callbacks = this.handlers.get(mutation.attributeName);
        if (callbacks) {
          const newValue = this.element.getAttribute(mutation.attributeName);
          callbacks.forEach((callback) => callback(newValue));
        }
      }
    }
  }
  destroy() {
    this.observer?.disconnect();
    this.handlers.clear();
  }
};

// js/components/dialog/dialog.js
var DialogStates = Object.freeze({
  FOREGROUND: "foreground",
  BACKGROUND: "background",
  HIDDEN: null
});
var Dialog = class _Dialog {
  static PARTS = {
    dialog: { selector: '[data-part="dialog"]', required: true },
    backdrop: { selector: "[data-part='backdrop']", required: true },
    content: { selector: '[data-part="content"]', required: true }
  };
  static CONFIG = {
    open: {
      type: "boolean",
      default: false
    },
    closeOnEsc: {
      type: "boolean",
      default: true
    },
    closeOnOutsideClick: {
      type: "boolean",
      default: true
    },
    preventClosing: {
      type: "boolean",
      default: false
    }
  };
  #parts;
  #config;
  #animator;
  #focusTrap;
  #stacker;
  #isOpen = false;
  #lastFocusedElement = null;
  #visibility = null;
  #isMouseDownInsideContent = false;
  constructor(element) {
    if (!element) throw new Error("Element is required");
    this.#parts = this.#initializeParts(element);
    this.#config = new Config(element, _Dialog.CONFIG);
    this.#animator = new Animator(element);
    this.#focusTrap = new FocusTrap(this.#parts.dialog, {
      content: this.#parts.content
    });
    this.#stacker = new Stacker();
    this.#bindEvents();
    new AttrObserver(element).watch("data-open", (value) => {
      if (value === "true") this.open();
      else if (value === "false") this.close();
    });
    if (this.#config.open) this.open();
  }
  #initializeParts(root) {
    const parts = { root };
    Object.entries(_Dialog.PARTS).forEach(([name, { selector, required, multiple, external }]) => {
      if (!selector) return;
      const elements = external ? document.querySelectorAll(selector) : root.querySelectorAll(selector);
      if (required && elements.length === 0) {
        throw new Error(`Required dialog part "${name}" not found`);
      }
      parts[name] = multiple ? Array.from(elements) : elements[0];
    });
    return Object.freeze(parts);
  }
  #bindEvents() {
    document.addEventListener("mousedown", this.#handleMouseDown);
    document.addEventListener("mouseup", this.#handleMouseUp);
  }
  async #updateOpenState(isOpen) {
    if (this.#isOpen === isOpen) return;
    this.#isOpen = isOpen;
    const { root, dialog, backdrop } = this.#parts;
    if (isOpen) {
      root.hidden = false;
      this.#lastFocusedElement = document.activeElement;
      this.#visibility = DialogStates.FOREGROUND;
      this.#focusTrap.activate();
      this.#focusTrap.focusFirst();
      this.#stacker.addDialog(this);
      await Promise.all([this.#animator.animateEnter(backdrop), this.#animator.animateEnter(dialog)]);
      root.dispatchEvent(new CustomEvent("fluxon:dialog:onOpen"));
    } else {
      await Promise.all([this.#animator.animateLeave(backdrop), this.#animator.animateLeave(dialog)]);
      root.hidden = true;
      if (this.#visibility === DialogStates.FOREGROUND) {
        this.#focusTrap.deactivate();
        this.#lastFocusedElement?.focus();
      }
      this.#stacker.removeDialog(this);
      root.dispatchEvent(new CustomEvent("fluxon:dialog:onClose"));
    }
  }
  #handleMouseDown = (event2) => {
    if (!this.#isOpen) return;
    this.#isMouseDownInsideContent = this.#parts.content.contains(event2.target);
  };
  #handleMouseUp = (event2) => {
    if (this.#isOpen && !this.#config.preventClosing && this.#config.closeOnOutsideClick && !this.#isMouseDownInsideContent && !this.#parts.content.contains(event2.target) && this.#visibility === DialogStates.FOREGROUND) {
      this.close();
    }
    this.#isMouseDownInsideContent = false;
  };
  handleEscape = () => {
    if (!this.#config.preventClosing && this.#config.closeOnEsc) {
      this.close();
    }
  };
  updateState(state) {
    this.#updateVisibility(state);
  }
  updateStackPosition(index) {
    this.#updateZIndex(1e3 + index * 10);
  }
  get config() {
    return this.#config;
  }
  #updateVisibility(visibility) {
    this.#visibility = visibility;
    if (visibility === DialogStates.BACKGROUND) {
      this.#focusTrap.deactivate();
    } else if (visibility === DialogStates.FOREGROUND) {
      this.#focusTrap.activate();
    }
  }
  #updateZIndex(zIndex) {
    this.#parts.root.style.zIndex = zIndex;
  }
  open() {
    return this.#updateOpenState(true);
  }
  close() {
    return this.#updateOpenState(false);
  }
  destroy() {
    document.removeEventListener("mousedown", this.#handleMouseDown);
    document.removeEventListener("mouseup", this.#handleMouseUp);
    if (this.#isOpen) this.#stacker.removeDialog(this);
    this.#focusTrap.deactivate();
  }
};

// js/hooks/dialog.js
var dialog_default = {
  mounted() {
    this.dialog = new Dialog(this.el);
    this.el.addEventListener("fluxon:dialog:onOpen", () => {
      if (this.el.dataset.onOpen) {
        liveSocket.execJS(this.el, this.el.dataset.onOpen);
      }
    });
    this.el.addEventListener("fluxon:dialog:onClose", () => {
      if (this.el.dataset.onClose) {
        liveSocket.execJS(this.el, this.el.dataset.onClose);
      }
    });
    this.el.addEventListener("fluxon:dialog:close", (event2) => {
      if (event2.target === this.el) {
        this.dialog.close();
      }
    });
    this.el.addEventListener("fluxon:dialog:open", (event2) => {
      if (event2.target === this.el) {
        this.dialog.open();
      }
    });
    window.addEventListener("phx:fluxon:dialog:close", (event2) => {
      if (event2.detail.id === `#${this.el.id}`) {
        this.dialog.close();
      }
    });
    window.addEventListener("phx:fluxon:dialog:open", (event2) => {
      if (event2.detail.id === `#${this.el.id}`) {
        this.dialog.open();
      }
    });
  },
  updated() {
  },
  destroyed() {
    this.dialog.destroy();
  },
  disconnected() {
  },
  reconnected() {
  }
};

// js/components/select/position.js
var Position3 = class {
  constructor(parts) {
    this.parts = parts;
    this.cleanup = null;
  }
  setup() {
    const updatePosition = () => {
      computePosition2(this.parts.toggle, this.parts.listbox, {
        placement: "bottom-start",
        strategy: "fixed",
        middleware: [
          offset2(5),
          shift2({ padding: 5 }),
          size2({
            padding: 20,
            apply: ({ availableHeight, rects }) => {
              const toggleRect = rects.reference;
              let finalHeight;
              if (this.parts.listbox.dataset.cachedMaxHeight) {
                const cachedHeight = parseInt(this.parts.listbox.dataset.cachedMaxHeight, 10);
                finalHeight = Math.min(cachedHeight, Math.max(150, availableHeight));
              } else if (!this.parts.listbox.dataset.heightChecked) {
                const cssMaxHeight = this.parts.listbox.style.maxHeight || window.getComputedStyle(this.parts.listbox).getPropertyValue("max-height");
                const hasExplicitHeight = cssMaxHeight && !["none", "auto"].includes(cssMaxHeight);
                if (hasExplicitHeight) {
                  const cssHeight = parseInt(cssMaxHeight, 10);
                  this.parts.listbox.dataset.cachedMaxHeight = cssHeight;
                  finalHeight = Math.min(cssHeight, Math.max(150, availableHeight));
                } else {
                  finalHeight = Math.max(150, availableHeight);
                }
                this.parts.listbox.dataset.heightChecked = "true";
              } else {
                finalHeight = Math.max(150, availableHeight);
              }
              Object.assign(this.parts.listbox.style, {
                maxHeight: `${finalHeight}px`,
                maxWidth: `${Math.max(toggleRect.width * 1.5, window.innerWidth - 20)}px`,
                minWidth: `${toggleRect.width}px`
              });
              void this.parts.listbox.offsetWidth;
            }
          }),
          flip2()
        ]
      }).then(({ x, y }) => {
        Object.assign(this.parts.listbox.style, {
          left: `${x}px`,
          top: `${y}px`
        });
      });
    };
    updatePosition();
    this.cleanup = autoUpdate(this.parts.toggle, this.parts.listbox, updatePosition);
    window.addEventListener("resize", updatePosition);
    const originalCleanup = this.cleanup;
    this.cleanup = () => {
      originalCleanup();
      window.removeEventListener("resize", updatePosition);
    };
  }
  destroy() {
    if (this.cleanup) {
      this.cleanup();
      this.cleanup = null;
      delete this.parts.listbox.dataset.cachedMaxHeight;
      delete this.parts.listbox.dataset.heightChecked;
    }
  }
};

// js/components/logger.js
var Logger = class {
  static #isEnabled = false;
  static event(component, event2, data = null) {
    if (!this.#isEnabled) return;
    console.groupCollapsed(`[${component}] ${event2}`);
    if (data) console.log("Data:", data);
    console.groupEnd();
  }
  static state(component, oldState, newState) {
    if (!this.#isEnabled) return;
    console.groupCollapsed(`[${component}] State Changed`);
    Object.entries(newState).forEach(([key, newValue]) => {
      console.log(`${key}:`, { from: oldState[key], to: newValue });
    });
    console.groupEnd();
  }
  static log(component, message, data = null) {
    if (!this.#isEnabled) return;
    if (data) {
      console.log(`[${component}] ${message}`, data);
    } else {
      console.log(`[${component}] ${message}`);
    }
  }
};

// js/components/select/select.js
var Select = class _Select {
  static PARTS = {
    toggle: { selector: '[data-part="toggle"]', required: true },
    toggleLabel: { selector: '[data-part="toggle-label"]', required: true },
    searchInput: { selector: '[data-part="search-input"]', required: false },
    listbox: { selector: '[data-part="listbox"]', required: true },
    select: { selector: '[data-part="select"]', required: true },
    emptyMessage: { selector: '[data-part="empty-message"]', required: true },
    loading: { selector: '[data-part="loading"]', required: true },
    options: { selector: '[data-part="option"]', required: false, multiple: true },
    optionsList: { selector: '[data-part="options-list"]', required: true },
    clearButton: { selector: '[data-part="clear"]' }
  };
  static CONFIG = {
    searchable: {
      type: "boolean",
      default: false
    },
    multiple: {
      type: "boolean",
      default: false
    },
    maxSelections: {
      type: "number",
      default: Infinity
    },
    searchNoResultsText: {
      type: "string",
      default: "No results found for {query}."
    },
    clearable: {
      type: "boolean",
      default: false
    },
    onSearch: {
      type: "string",
      default: null
    },
    debounceMs: {
      type: "number",
      default: 300
    },
    searchThreshold: {
      type: "number",
      default: 0
    },
    computed: {
      canSearch: (config) => config.searchable
    }
  };
  #isOpen = false;
  #highlightedIndex = -1;
  #searchQuery = "";
  #typeaheadQuery = "";
  #typeaheadTimeout = null;
  #searchTimeout = null;
  #focusOutTimeout = null;
  #activeSearchEvents = 0;
  #isServerSearching = false;
  #isUpdatingFromLiveView = false;
  #options;
  #parts;
  #config;
  #position;
  #animator;
  constructor(element) {
    if (!element) throw new Error("Element is required");
    Logger.log("Select", "Initializing component");
    this.#initializeComponent(element);
    this.#bindBaseEvents();
  }
  #initializeComponent(element) {
    this.#parts = this.#initializeParts(element);
    this.#config = new Config(element, _Select.CONFIG);
    this.#position = new Position3(this.#parts);
    this.#animator = new Animator(element);
    this.#options = this.#initializeOptions();
  }
  #initializeParts(root) {
    return Object.freeze({
      root,
      ...Object.fromEntries(
        Object.entries(_Select.PARTS).map(([name, { selector, required, multiple }]) => {
          const elements = root.querySelectorAll(selector);
          if (required && (!elements || multiple && elements.length === 0)) {
            throw new Error(`Required select part "${name}" not found`);
          }
          return [name, multiple ? Array.from(elements) : elements[0]];
        })
      )
    });
  }
  #initializeOptions() {
    return Array.from(this.#parts.select.querySelectorAll("option:not([value=''])")).map((option) => ({
      value: option.value,
      label: option.textContent || option.value,
      isVisible: true,
      isSelected: option.selected
    }));
  }
  #bindBaseEvents() {
    const { toggle } = this.#parts;
    toggle.addEventListener("click", this.#handleToggleClick);
    toggle.addEventListener("keydown", this.#handleKeyDown);
    toggle.addEventListener("focus", this.#handleToggleFocus);
    toggle.addEventListener("blur", this.#handleToggleBlur);
    this.#parts.root.addEventListener("focusout", this.#handleFocusOut);
    if (this.#config.clearable && this.#parts.clearButton) {
      this.#parts.clearButton.addEventListener("mousedown", (e) => e.preventDefault());
      this.#parts.clearButton.addEventListener("click", this.#handleClearClick);
    }
  }
  #handleToggleClick = (event2) => {
    if (this.#config.clearable && event2.target.closest('[data-part="clear"]')) {
      this.#handleClearClick(event2);
      return;
    }
    if (this.#isOpen) {
      this.#closeListbox();
      this.#parts.toggle.focus();
      this.#parts.toggle.setAttribute("data-focused", "");
    } else {
      this.#openListbox();
    }
  };
  #handleKeyDown = (event2) => {
    const keyHandlers = {
      ArrowDown: () => this.#handleArrowKey("next", event2),
      ArrowUp: () => this.#handleArrowKey("previous", event2),
      Enter: () => this.#handleEnterKey(event2),
      Escape: () => this.#handleEscapeKey(event2),
      Home: () => this.#handleHomeKey(event2),
      End: () => this.#handleEndKey(event2),
      Backspace: () => this.#handleBackspaceKey(event2)
    };
    const handler = keyHandlers[event2.key];
    if (handler) {
      handler();
    } else if (event2.key.length === 1 && event2.key.match(/\S/)) {
      this.#handleTypeahead(event2.key);
    }
  };
  #handleArrowKey(direction, event2) {
    event2.preventDefault();
    event2.stopPropagation();
    if (this.#isOpen) {
      this.#highlightAdjacentOption(direction);
    } else {
      this.#openListbox();
      const lastSelectedIndex = [...this.#options].reverse().findIndex((opt) => opt.isSelected);
      const selectedIndex = lastSelectedIndex !== -1 ? this.#options.length - 1 - lastSelectedIndex : -1;
      if (selectedIndex !== -1) {
        this.#highlightOption(selectedIndex);
      } else {
        direction === "next" ? this.#highlightFirstOption() : this.#highlightLastOption();
      }
    }
  }
  #handleEnterKey(event2) {
    event2.preventDefault();
    if (this.#config.clearable && event2.target.closest('[data-part="clear"]')) {
      this.#handleClearClick(event2);
      return;
    }
    if (this.#isOpen) {
      this.#selectHighlightedOption();
    } else {
      this.#openListbox();
    }
  }
  #selectHighlightedOption() {
    if (this.#highlightedIndex !== -1) {
      this.#toggleOption(this.#options[this.#highlightedIndex].value);
    } else {
      this.#closeListbox();
      this.#parts.toggle.focus();
    }
  }
  #handleEscapeKey(event2) {
    event2.preventDefault();
    if (this.#isOpen) event2.stopPropagation();
    this.#closeListbox();
    this.#parts.toggle.focus();
  }
  #handleHomeKey(event2) {
    if (this.#isOpen) {
      event2.preventDefault();
      this.#highlightFirstOption();
    }
  }
  #handleEndKey(event2) {
    if (this.#isOpen) {
      event2.preventDefault();
      this.#highlightLastOption();
    }
  }
  #handleTypeahead(char) {
    this.#updateTypeaheadQuery(char);
    this.#highlightTypeaheadMatch();
  }
  #updateTypeaheadQuery(char) {
    this.#typeaheadQuery += char.toLowerCase();
    if (this.#typeaheadTimeout) {
      clearTimeout(this.#typeaheadTimeout);
    }
    this.#typeaheadTimeout = setTimeout(() => {
      this.#resetTypeahead();
    }, 300);
  }
  #resetTypeahead() {
    this.#typeaheadQuery = "";
    this.#typeaheadTimeout = null;
  }
  #highlightTypeaheadMatch() {
    const index = this.#findMatchingOption(this.#typeaheadQuery);
    if (index !== -1) {
      this.#highlightOption(index);
      if (!this.#isOpen) {
        this.#toggleOption(this.#options[index].value);
      }
    }
  }
  #highlightOption(index, scroll = true) {
    Logger.event("Select", "highlightOption", {
      previousIndex: this.#highlightedIndex,
      newIndex: index
    });
    this.#clearCurrentHighlight();
    this.#setNewHighlight(index);
    if (scroll) this.#scrollToHighlightedOption(index);
    this.#updateAriaAttributes(index);
  }
  #clearCurrentHighlight() {
    if (this.#highlightedIndex !== -1 && this.#parts.options[this.#highlightedIndex]) {
      const currentOption = this.#parts.options[this.#highlightedIndex];
      currentOption.removeAttribute("data-highlighted");
      currentOption.setAttribute("aria-selected", "false");
    }
  }
  #clearAllHighlights() {
    this.#parts.options.forEach((option) => {
      option.removeAttribute("data-highlighted");
      option.setAttribute("aria-selected", "false");
    });
    this.#highlightedIndex = -1;
    this.#parts.toggle.removeAttribute("aria-activedescendant");
  }
  #setNewHighlight(index) {
    this.#highlightedIndex = index;
    if (index !== -1 && this.#parts.options[index]) {
      const newOption = this.#parts.options[index];
      newOption.setAttribute("data-highlighted", "");
      newOption.setAttribute("aria-selected", "true");
    }
  }
  #scrollToHighlightedOption(index) {
    if (index !== -1 && this.#parts.options[index] && this.#parts.optionsList.scrollHeight > this.#parts.optionsList.clientHeight) {
      this.#parts.options[index].scrollIntoView({ block: "nearest", behavior: "auto" });
    }
  }
  #updateAriaAttributes(index) {
    if (index !== -1 && this.#parts.options[index]) {
      this.#parts.toggle.setAttribute("aria-activedescendant", this.#parts.options[index].id);
    } else {
      this.#parts.toggle.removeAttribute("aria-activedescendant");
    }
  }
  #handleOutsideClick = (event2) => {
    if (!this.#parts.root.contains(event2.target)) {
      this.#closeListbox();
    }
  };
  #handleOptionClick = (event2) => {
    event2.preventDefault();
    const option = event2.target.closest('[data-part="option"]');
    if (option) {
      const value = option.dataset.value;
      this.#toggleOption(value);
    }
  };
  #handleOptionHover = (event2) => {
    const option = event2.target.closest('[data-part="option"]');
    if (option) {
      const index = this.#options.findIndex((opt) => opt.value === option.dataset.value);
      if (index !== -1) {
        this.#highlightOption(index, false);
      }
    }
  };
  #handleSearchInput = (event2) => {
    event2.preventDefault();
    event2.stopPropagation();
    const oldQuery = this.#searchQuery;
    this.#searchQuery = event2.target.value.trim();
    Logger.event("Select", "search", {
      oldQuery,
      newQuery: this.#searchQuery
    });
    if (this.#searchQuery === "" && this.#config.onSearch) {
      this.#performServerSearch();
      return;
    }
    if (this.#searchQuery.length > 0 && this.#searchQuery.length < this.#config.searchThreshold) {
      if (this.#config.onSearch) {
        this.#parts.loading.hidden = true;
        const hasVisibleOptions = this.#hasVisibleOptions();
        if (hasVisibleOptions) {
          this.#parts.optionsList.hidden = false;
          this.#parts.emptyMessage.hidden = true;
        } else {
          this.#parts.optionsList.hidden = true;
          this.#parts.emptyMessage.hidden = false;
        }
      } else {
        this.#options.forEach((opt) => opt.isVisible = true);
        this.#updateOptions();
        this.#updateEmptyMessage();
      }
      return;
    }
    if (this.#config.onSearch) {
      this.#performServerSearch();
    } else {
      this.#updateOptionsVisibility();
      this.#updateListboxState();
    }
  };
  #performServerSearch() {
    if (this.#searchTimeout) {
      clearTimeout(this.#searchTimeout);
    }
    this.#isServerSearching = true;
    this.#highlightedIndex = -1;
    this.#clearAllHighlights();
    this.#parts.loading.hidden = false;
    this.#parts.optionsList.hidden = true;
    this.#parts.emptyMessage.hidden = true;
    this.#searchTimeout = setTimeout(() => {
      this.#activeSearchEvents++;
      const eventDetail = {
        query: this.#searchQuery,
        id: this.#parts.select.id || this.#parts.root.id,
        // Ensure an ID is available
        callback: this.#config.onSearch,
        // The event name to push to the server
        onComplete: () => {
          this.#activeSearchEvents--;
          if (this.#activeSearchEvents === 0) {
            this.#isServerSearching = false;
            this.#parts.loading.hidden = true;
            this.#options = this.#initializeOptions();
            this.#options.forEach((opt) => opt.isVisible = true);
            this.#parts = this.#initializeParts(this.#parts.root);
            this.#clearAllHighlights();
            this.#updateToggleLabel();
            this.#updateOptions();
            this.#updateEmptyMessage();
            if (this.#hasVisibleOptions()) {
              this.#highlightFirstVisibleOption();
            }
            Logger.event("Select", "serverSearchComplete", {
              query: this.#searchQuery,
              optionsCount: this.#options.length,
              visibleOptionsCount: this.#options.filter((opt) => opt.isVisible).length
            });
          }
        },
        onError: () => {
          this.#activeSearchEvents--;
          if (this.#activeSearchEvents === 0) {
            this.#isServerSearching = false;
            this.#parts.loading.hidden = true;
            this.#clearAllHighlights();
            this.#parts.emptyMessage.innerHTML = "Error occurred while searching. Please try again.";
            this.#parts.emptyMessage.hidden = false;
            this.#parts.optionsList.hidden = true;
            Logger.event("Select", "serverSearchError", { query: this.#searchQuery });
          }
        }
      };
      Logger.event("Select", "serverSearchStart", { query: this.#searchQuery });
      this.#parts.root.dispatchEvent(
        new CustomEvent("fluxon:select:search", {
          // Custom event name for select
          bubbles: true,
          detail: eventDetail
        })
      );
    }, this.#config.debounceMs);
  }
  #updateOptionsVisibility() {
    if (this.#config.onSearch && this.#isServerSearching) {
      return;
    }
    const query = this.#normalizeString(this.#searchQuery);
    this.#options.forEach((option) => {
      option.isVisible = this.#optionMatchesSearch(option, query);
    });
    this.#updateOptions();
  }
  #optionMatchesSearch(option, query) {
    return this.#normalizeString(option.label).includes(query);
  }
  #updateListboxState() {
    this.#clearAllHighlights();
    if (this.#hasVisibleOptions()) {
      this.#highlightFirstVisibleOption();
    }
    this.#updateEmptyMessage();
  }
  #toggleOption(value) {
    const index = this.#options.findIndex((opt) => opt.value === value);
    if (index === -1) return;
    Logger.event("Select", "toggleOption", { value, index });
    if (!this.#config.multiple) {
      this.#handleSingleSelect(index);
    } else {
      this.#handleMultipleSelect(index);
    }
    this.#highlightedIndex = index;
    if (!this.#config.multiple) {
      this.#parts.toggle.focus();
      this.#parts.toggle.setAttribute("data-focused", "");
    }
  }
  #handleSingleSelect(index) {
    if (this.#config.clearable && this.#options[index].isSelected) {
      this.#options[index].isSelected = false;
      this.#updateSelection();
      this.#closeListbox();
      this.#parts.toggle.focus();
      this.#parts.toggle.setAttribute("data-focused", "");
      return;
    }
    if (this.#options[index].isSelected) return;
    this.#setSelectedOption(index);
    this.#closeListbox();
    this.#parts.toggle.focus();
    this.#parts.toggle.setAttribute("data-focused", "");
  }
  #handleMultipleSelect(index) {
    const selectedCount = this.#options.filter((opt) => opt.isSelected).length;
    if (selectedCount >= this.#config.maxSelections && !this.#options[index].isSelected) {
      return;
    }
    this.#toggleOptionSelection(index);
    this.#maintainCurrentFocus();
  }
  /**
   * Maintains the current focus state without stealing focus.
   * This is particularly important for multiple selection with search.
   */
  #maintainCurrentFocus() {
    if (this.#isOpen && this.#config.canSearch) {
      if (document.activeElement !== this.#parts.searchInput) {
        this.#parts.searchInput.focus();
      }
    }
    if (this.#isOpen) {
      this.#parts.toggle.setAttribute("data-focused", "");
    }
  }
  #setSelectedOption(index) {
    this.#options.forEach((opt, i) => opt.isSelected = i === index);
    this.#updateSelection();
  }
  #toggleOptionSelection(index) {
    this.#options[index].isSelected = !this.#options[index].isSelected;
    this.#updateSelection();
  }
  #updateSelection() {
    const oldState = {
      selectedOptions: this.#options.filter((opt) => opt.isSelected),
      toggleLabel: this.#parts.toggleLabel.textContent
    };
    this.#updateNativeSelect();
    this.#updateToggleLabel();
    this.#updateOptions();
    if (this.#config.clearable) {
      this.#updateClearButtonVisibility();
    }
    const newState = {
      selectedOptions: this.#options.filter((opt) => opt.isSelected),
      toggleLabel: this.#parts.toggleLabel.textContent
    };
    Logger.state("Select", oldState, newState);
  }
  #updateClearButtonVisibility() {
    const { clearButton } = this.#parts;
    const hasSelectedOptions = this.#options.some((opt) => opt.isSelected);
    clearButton.hidden = !hasSelectedOptions;
  }
  #updateToggleLabel() {
    const selectedOptions = this.#options.filter((opt) => opt.isSelected);
    this.#parts.toggleLabel.textContent = selectedOptions.length ? selectedOptions.map((opt) => opt.label).join(", ") : "";
  }
  #updateNativeSelect() {
    const selectedOptions = this.#options.filter((opt) => opt.isSelected);
    Array.from(this.#parts.select.options).forEach((option) => {
      const isSelected = selectedOptions.some((opt) => opt.value === option.value);
      option.selected = isSelected;
      option.setAttribute("aria-selected", isSelected.toString());
    });
    Logger.event("Select", "change", {
      selectedValues: selectedOptions.map((opt) => opt.value),
      selectedLabels: selectedOptions.map((opt) => opt.label)
    });
    this.#parts.select.dispatchEvent(new Event("change", { bubbles: true }));
  }
  #highlightAdjacentOption(direction) {
    const visibleOptions = this.#options.filter((opt) => opt.isVisible);
    if (visibleOptions.length === 0) return;
    let currentVisibleIndex = -1;
    if (this.#highlightedIndex !== -1) {
      currentVisibleIndex = visibleOptions.findIndex((opt) => opt === this.#options[this.#highlightedIndex]);
    }
    let newVisibleIndex;
    if (currentVisibleIndex === -1) {
      newVisibleIndex = direction === "next" ? 0 : visibleOptions.length - 1;
    } else {
      newVisibleIndex = direction === "next" ? Math.min(currentVisibleIndex + 1, visibleOptions.length - 1) : Math.max(currentVisibleIndex - 1, 0);
    }
    const newActualIndex = this.#options.findIndex((opt) => opt === visibleOptions[newVisibleIndex]);
    this.#highlightOption(newActualIndex);
  }
  #highlightFirstOption() {
    const firstVisibleIndex = this.#options.findIndex((opt) => opt.isVisible);
    if (firstVisibleIndex !== -1) {
      this.#highlightOption(firstVisibleIndex);
    }
  }
  #highlightLastOption() {
    const reversedIndex = [...this.#options].reverse().findIndex((opt) => opt.isVisible);
    if (reversedIndex !== -1) {
      const lastVisibleIndex = this.#options.length - 1 - reversedIndex;
      this.#highlightOption(lastVisibleIndex);
    }
  }
  #highlightFirstVisibleOption() {
    const index = this.#options.findIndex((opt) => opt.isVisible);
    if (index !== -1) {
      this.#highlightOption(index);
    }
  }
  #findMatchingOption(query) {
    const normalizedQuery = this.#normalizeString(query);
    return this.#options.findIndex(
      (opt) => this.#isOptionVisible(opt) && this.#optionStartsWithQuery(opt, normalizedQuery)
    );
  }
  #isOptionVisible(option) {
    return option.isVisible;
  }
  #optionStartsWithQuery(option, query) {
    return this.#normalizeString(option.label).startsWith(query);
  }
  #normalizeString(str) {
    return str.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "");
  }
  async #openListbox() {
    if (this.#isOpen) return;
    Logger.event("Select", "openListbox");
    this.#bindListboxEvents();
    if (this.#config.canSearch) {
      this.#searchQuery = this.#parts.searchInput.value.trim();
    }
    if (this.#highlightedIndex !== -1) {
      this.#highlightOption(this.#highlightedIndex);
    }
    await this.#showListbox();
    this.#handleInitialFocus();
  }
  #showListbox() {
    const { root, toggle, listbox } = this.#parts;
    this.#isOpen = true;
    toggle.setAttribute("aria-expanded", "true");
    toggle.setAttribute("data-focused", "");
    root.setAttribute("data-expanded", "");
    this.#position.setup();
    listbox.hidden = false;
    return this.#animator.animateEnter(listbox);
  }
  #bindListboxEvents() {
    const { listbox, searchInput } = this.#parts;
    document.addEventListener("click", this.#handleOutsideClick);
    listbox.addEventListener("click", this.#handleOptionClick);
    listbox.addEventListener("mouseover", this.#handleOptionHover);
    listbox.addEventListener("mousedown", this.#handleListboxMouseDown);
    if (this.#config.canSearch) {
      searchInput.addEventListener("touchstart", (e) => {
        e.preventDefault();
        searchInput.focus();
      });
      searchInput.addEventListener("input", this.#handleSearchInput);
      searchInput.addEventListener("keydown", this.#handleKeyDown);
      searchInput.addEventListener("change", function(e) {
        e.preventDefault();
        e.stopPropagation();
      });
    }
  }
  #handleInitialFocus() {
    if (this.#config.canSearch) {
      this.#parts.searchInput.focus();
      this.#parts.searchInput.click();
      this.#parts.toggle.setAttribute("data-focused", "");
    }
  }
  async #closeListbox() {
    if (!this.#isOpen) return;
    Logger.event("Select", "closeListbox");
    this.#unbindListboxEvents();
    await this.#hideListbox();
    this.#cleanupListboxState();
  }
  async #hideListbox() {
    const { root, toggle, listbox } = this.#parts;
    this.#isOpen = false;
    toggle.setAttribute("aria-expanded", "false");
    toggle.removeAttribute("data-focused");
    root.removeAttribute("data-expanded");
    if (await this.#animator.animateLeave(listbox)) {
      listbox.hidden = true;
      this.#position.destroy();
    }
  }
  #cleanupListboxState() {
    this.#resetSearch();
    this.#resetHighlight();
  }
  #resetSearch() {
    if (!this.#config.onSearch) {
      this.#searchQuery = "";
      if (this.#config.canSearch && !this.#config.onSearch) this.#parts.searchInput.value = "";
      this.#options.forEach((opt) => opt.isVisible = true);
      this.#updateEmptyMessage();
      this.#updateOptions();
    }
  }
  #resetHighlight() {
    if (this.#highlightedIndex !== -1 && this.#parts.options[this.#highlightedIndex]) {
      this.#parts.options[this.#highlightedIndex].removeAttribute("data-highlighted");
      this.#parts.options[this.#highlightedIndex].setAttribute("aria-selected", "false");
    }
    const selectedIndex = this.#options.findIndex((opt) => opt.isSelected);
    this.#highlightedIndex = selectedIndex !== -1 ? selectedIndex : -1;
    this.#parts.toggle.removeAttribute("aria-activedescendant");
  }
  #unbindListboxEvents() {
    const { listbox, clearButton } = this.#parts;
    document.removeEventListener("click", this.#handleOutsideClick);
    listbox.removeEventListener("click", this.#handleOptionClick);
    listbox.removeEventListener("mouseover", this.#handleOptionHover);
    listbox.removeEventListener("mousedown", this.#handleListboxMouseDown);
    if (clearButton) {
      clearButton.removeEventListener("click", this.#handleClearClick);
    }
    if (this.#config.canSearch) {
      this.#parts.searchInput.removeEventListener("touchstart", this.#handleSearchInput);
      this.#parts.searchInput.removeEventListener("input", this.#handleSearchInput);
      this.#parts.searchInput.removeEventListener("keydown", this.#handleKeyDown);
    }
  }
  #updateOptions() {
    this.#parts.options.forEach((optionEl, index) => {
      const option = this.#options[index];
      if (option) {
        optionEl.hidden = !option.isVisible;
        if (option.isSelected) {
          optionEl.setAttribute("data-selected", "");
          optionEl.setAttribute("aria-selected", "true");
        } else {
          optionEl.removeAttribute("data-selected");
          optionEl.setAttribute("aria-selected", "false");
        }
        optionEl.setAttribute("aria-disabled", (!option.isVisible).toString());
      }
    });
  }
  #updateEmptyMessage() {
    const hasVisibleOptions = this.#hasVisibleOptions();
    const message = this.#getEmptyMessage(hasVisibleOptions);
    this.#updateEmptyMessageDisplay(message);
    this.#updateListboxExpandedState(hasVisibleOptions);
    this.#parts.optionsList.hidden = !hasVisibleOptions;
  }
  #hasVisibleOptions() {
    return this.#options.some((opt) => opt.isVisible);
  }
  #getEmptyMessage(hasVisibleOptions) {
    if (hasVisibleOptions) return "";
    return this.#config.searchNoResultsText.replace("%{query}", `<strong>${this.#searchQuery}</strong>`);
  }
  #updateEmptyMessageDisplay(message) {
    this.#parts.emptyMessage.innerHTML = message;
    this.#parts.emptyMessage.hidden = !message;
  }
  #updateListboxExpandedState(hasVisibleOptions) {
    this.#parts.listbox.setAttribute("aria-expanded", hasVisibleOptions.toString());
  }
  // Handles mousedown events on the listbox element.
  // Prevents the default mousedown behavior (which would cause blur/focus changes)
  // when clicking anywhere in the listbox except the toggle button.
  // This is particularly important for maintaining focus on the search input
  // when clicking anywhere in the listbox except the toggle button.
  #handleListboxMouseDown = (event2) => {
    if (event2.target !== this.#parts.toggle) {
      event2.preventDefault();
    }
  };
  reload() {
    Logger.event("Select", "reload");
    this.#isUpdatingFromLiveView = true;
    const oldOptions = [...this.#options];
    let preservedHighlightValue = null;
    if (this.#config.multiple && this.#isOpen && this.#highlightedIndex !== -1) {
      preservedHighlightValue = this.#options[this.#highlightedIndex]?.value;
    }
    let visibilityState;
    if (!this.#isServerSearching) {
      visibilityState = new Map(this.#options.map((option) => [option.value, option.isVisible]));
    }
    this.#options = this.#initializeOptions().map((option) => {
      let isVisible = true;
      if (visibilityState && visibilityState.has(option.value)) {
        isVisible = visibilityState.get(option.value);
      }
      return {
        ...option,
        isVisible
      };
    });
    this.#parts = this.#initializeParts(this.#parts.root);
    if (this.#config.multiple && this.#isOpen && preservedHighlightValue) {
      const newIndex = this.#options.findIndex((opt) => opt.value === preservedHighlightValue);
      if (newIndex !== -1) {
        this.#highlightedIndex = newIndex;
        if (this.#parts.options[newIndex]) {
          this.#parts.options[newIndex].setAttribute("data-highlighted", "");
          this.#parts.options[newIndex].setAttribute("aria-selected", "true");
          this.#parts.toggle.setAttribute("aria-activedescendant", this.#parts.options[newIndex].id);
        }
      } else {
        this.#clearAllHighlights();
      }
    } else {
      this.#clearAllHighlights();
    }
    this.#updateToggleLabel();
    this.#updateOptions();
    this.#updateEmptyMessage();
    this.#isUpdatingFromLiveView = false;
    Logger.state("Select", { options: oldOptions }, { options: this.#options });
  }
  destroy() {
    Logger.event("Select", "destroy");
    const { toggle, listbox, searchInput } = this.#parts;
    toggle.removeEventListener("click", this.#handleToggleClick);
    toggle.removeEventListener("keydown", this.#handleKeyDown);
    toggle.removeEventListener("focus", this.#handleToggleFocus);
    toggle.removeEventListener("blur", this.#handleToggleBlur);
    this.#parts.root.removeEventListener("focusout", this.#handleFocusOut);
    if (this.#config.canSearch) {
      searchInput.removeEventListener("input", this.#handleSearchInput);
      searchInput.removeEventListener("keydown", this.#handleKeyDown);
    }
    if (this.#isOpen) {
      document.removeEventListener("click", this.#handleOutsideClick);
      listbox.removeEventListener("click", this.#handleOptionClick);
      listbox.removeEventListener("mouseover", this.#handleOptionHover);
    }
    if (this.#typeaheadTimeout) {
      clearTimeout(this.#typeaheadTimeout);
    }
    if (this.#searchTimeout) {
      clearTimeout(this.#searchTimeout);
    }
    if (this.#focusOutTimeout) {
      clearTimeout(this.#focusOutTimeout);
      this.#focusOutTimeout = null;
    }
    this.#position.destroy();
  }
  #handleFocusOut = (event2) => {
    if (this.#isUpdatingFromLiveView) {
      return;
    }
    if (this.#focusOutTimeout) {
      clearTimeout(this.#focusOutTimeout);
      this.#focusOutTimeout = null;
    }
    this.#focusOutTimeout = setTimeout(() => {
      const activeElement = document.activeElement;
      const { toggle, listbox } = this.#parts;
      const focusWithinComponent = activeElement && (activeElement === toggle || listbox.contains(activeElement) || this.#parts.root.contains(activeElement));
      if (!focusWithinComponent) {
        this.#closeListbox();
      }
    }, 10);
  };
  #handleToggleFocus = () => {
    this.#parts.toggle.setAttribute("data-focused", "");
  };
  #handleToggleBlur = () => {
    const focusNode = event.relatedTarget;
    if (!this.#isOpen && (!focusNode || !this.#parts.listbox.contains(focusNode))) {
      this.#parts.toggle.removeAttribute("data-focused");
    }
  };
  #handleClearClick = (event2) => {
    event2.preventDefault();
    event2.stopPropagation();
    Logger.event("Select", "clear");
    this.#options.forEach((opt) => opt.isSelected = false);
    this.#updateSelection();
    this.#closeListbox();
    this.#parts.toggle.focus();
    this.#parts.toggle.setAttribute("data-focused", "");
  };
  #handleBackspaceKey(event2) {
    if (!this.#config.clearable) return;
    const hasSelectedOptions = this.#options.some((opt) => opt.isSelected);
    if (hasSelectedOptions && event2.target !== this.#parts.searchInput) {
      event2.preventDefault();
      this.#handleClearClick(event2);
    }
  }
};

// js/hooks/select.js
var select_default = {
  mounted() {
    this.select = new Select(this.el);
    this.el.addEventListener("fluxon:select:search", (event2) => {
      this.pushEventTo(
        this.el,
        event2.detail.callback,
        { query: event2.detail.query, id: event2.detail.id },
        (reply, ref) => {
          if (event2.detail.onComplete) {
            event2.detail.onComplete();
          }
        },
        (reason, ref) => {
          if (event2.detail.onError) {
            event2.detail.onError();
          }
        }
      );
    });
  },
  updated() {
    this.select.reload();
  },
  destroyed() {
    this.select.destroy();
  },
  disconnected() {
  },
  reconnected() {
  }
};

// js/components/accordion/accordion.js
var Accordion = class _Accordion {
  static PARTS = {
    items: { selector: '[data-part="item"]', required: true, multiple: true },
    headers: { selector: '[data-part="header"]', required: true, multiple: true },
    panels: { selector: '[data-part="panel"]', required: true, multiple: true }
  };
  static CONFIG = {
    multiple: {
      type: "boolean",
      default: false
    },
    preventAllClosed: {
      type: "boolean",
      default: false
    },
    animationDuration: {
      type: "number",
      default: 300
    },
    computed: {
      canCloseAll: (config) => !config.preventAllClosed,
      canOpenMultiple: (config) => config.multiple
    }
  };
  #parts;
  #config;
  #openIndexes = [];
  #boundHandlers = /* @__PURE__ */ new Map();
  constructor(element) {
    if (!element) throw new Error("Element is required");
    Logger.log("Accordion", "Initializing component");
    this.#parts = this.#initializeParts(element);
    this.#config = new Config(element, _Accordion.CONFIG);
    this.#validateConfiguration();
    this.#setupInitialState();
    this.#setupUI();
  }
  #initializeParts(root) {
    const parts = { root };
    Object.entries(_Accordion.PARTS).forEach(([name, { selector, required, multiple }]) => {
      const elements = root.querySelectorAll(selector);
      if (required && (!elements || elements.length === 0)) {
        throw new Error(`Required part "${name}" not found`);
      }
      parts[name] = multiple ? Array.from(elements) : elements[0];
    });
    if (parts.items.length === 0) {
      throw new Error("Accordion must contain at least one item");
    }
    if (parts.items.length !== parts.headers.length || parts.items.length !== parts.panels.length) {
      throw new Error("Mismatch in number of accordion items, headers, or panels");
    }
    Logger.log("Accordion", "Parts initialized", parts);
    return Object.freeze(parts);
  }
  #validateConfiguration() {
    const expandedItems = this.#parts.items.filter((item) => item.hasAttribute("data-expanded"));
    if (!this.#config.canOpenMultiple && expandedItems.length > 1) {
      console.warn("Multiple expanded items specified when `multiple` is false. Only the first item will be expanded.");
    }
    if (!this.#config.canCloseAll && expandedItems.length === 0) {
      throw new Error(
        "Invalid configuration: When `prevent_all_closed` is true, at least one item must be expanded by default."
      );
    }
    Logger.log("Accordion", "Configuration validated");
  }
  #setupInitialState() {
    this.#openIndexes = this.#parts.items.map((item, index) => ({ item, index })).filter(({ item }) => item.hasAttribute("data-expanded")).map(({ index }) => index);
    if (!this.#config.canOpenMultiple && this.#openIndexes.length > 1) {
      this.#openIndexes = [this.#openIndexes[0]];
    }
    Logger.log("Accordion", "Initial state set up", { openIndexes: this.#openIndexes });
  }
  #setupUI() {
    const { headers, panels } = this.#parts;
    headers.forEach((header, index) => {
      header.setAttribute("role", "button");
      header.setAttribute("aria-controls", panels[index].id);
      header.setAttribute("aria-expanded", "false");
      header.setAttribute("aria-disabled", "false");
      panels[index].setAttribute("aria-labelledby", header.id);
      panels[index].setAttribute("aria-hidden", "true");
      const handlers = {
        click: () => this.toggleItem(index),
        keydown: (e) => this.#handleKeyDown(e, index)
      };
      Object.entries(handlers).forEach(([event2, handler]) => {
        header.addEventListener(event2, handler);
        this.#boundHandlers.set(`${index}-${event2}`, { element: header, event: event2, handler });
      });
    });
    this.#updateAccordionState();
    Logger.log("Accordion", "UI set up");
  }
  #updateAccordionState() {
    const { items, headers, panels } = this.#parts;
    items.forEach((item, index) => {
      const isExpanded = this.#openIndexes.includes(index);
      const header = headers[index];
      const panel = panels[index];
      header.setAttribute("aria-expanded", isExpanded.toString());
      header.setAttribute(
        "aria-disabled",
        (!isExpanded && this.#openIndexes.length === 1 && !this.#config.canCloseAll).toString()
      );
      panel.setAttribute("aria-hidden", (!isExpanded).toString());
      if (isExpanded) {
        item.setAttribute("data-expanded", "");
        panel.hidden = false;
        panel.style.height = "0";
        requestAnimationFrame(() => {
          panel.style.height = `${panel.scrollHeight}px`;
        });
      } else if (!panel.hidden) {
        item.removeAttribute("data-expanded");
        panel.style.height = `${panel.scrollHeight}px`;
        requestAnimationFrame(() => {
          panel.style.height = "0";
          setTimeout(() => {
            panel.hidden = true;
          }, this.#config.animationDuration);
        });
      }
    });
  }
  #handleKeyDown(event2, index) {
    const { headers } = this.#parts;
    const keyHandlers = {
      ArrowUp: () => this.#focusHeader(index - 1),
      ArrowDown: () => this.#focusHeader(index + 1),
      Home: () => this.#focusHeader(0),
      End: () => this.#focusHeader(headers.length - 1),
      Enter: () => this.toggleItem(index),
      " ": () => this.toggleItem(index)
    };
    const handler = keyHandlers[event2.key];
    if (handler && event2.key !== "Tab") {
      event2.preventDefault();
      handler();
    }
  }
  #focusHeader(index) {
    const { headers } = this.#parts;
    const targetIndex = (index + headers.length) % headers.length;
    headers[targetIndex].focus();
  }
  // Public API
  toggleItem(index) {
    Logger.event("Accordion", "toggleItem", { index });
    if (this.#openIndexes.includes(index)) {
      this.#closeItem(index);
    } else {
      this.#openItem(index);
    }
  }
  #openItem(index) {
    if (this.#openIndexes.includes(index)) return;
    const newIndexes = this.#config.canOpenMultiple ? [...this.#openIndexes, index] : [index];
    this.#openIndexes = newIndexes;
    this.#updateAccordionState();
    Logger.log("Accordion", "Item opened", { index });
  }
  #closeItem(index) {
    if (!this.#openIndexes.includes(index)) return;
    const newIndexes = this.#openIndexes.filter((i) => i !== index);
    if (!this.#config.canCloseAll && newIndexes.length === 0) return;
    this.#openIndexes = newIndexes;
    this.#updateAccordionState();
    Logger.log("Accordion", "Item closed", { index });
  }
  destroy() {
    this.#boundHandlers.forEach(({ element, event: event2, handler }) => {
      element.removeEventListener(event2, handler);
    });
    this.#boundHandlers.clear();
    Logger.log("Accordion", "Component destroyed");
  }
};

// js/hooks/accordion.js
var accordion_default = {
  mounted() {
    this.accordion = new Accordion(this.el);
  },
  updated() {
  },
  destroyed() {
    this.accordion.destroy();
  },
  disconnected() {
  },
  reconnected() {
  }
};

// js/components/utils.js
var toKebabCase = (str) => {
  if (!str) return "";
  if (typeof str !== "string") return "";
  return str.replace(/([A-Z]+)([A-Z][a-z])/g, "$1-$2").replace(/([a-z])([A-Z])/g, "$1-$2").toLowerCase();
};
var toCamelCase = (str) => {
  if (!str) return "";
  if (typeof str !== "string") return "";
  return str.replace(/[^a-zA-Z0-9]+(.)/g, (_, chr) => chr.toUpperCase());
};

// js/components/component.js
function isEqual(a, b) {
  if (a === b) return true;
  if (a == null || b == null) return a === b;
  if (typeof a !== "object" || typeof b !== "object") return a === b;
  if (Array.isArray(a)) {
    if (!Array.isArray(b) || a.length !== b.length) return false;
    return a.every((item, index) => isEqual(item, b[index]));
  }
  const keysA = Object.keys(a);
  const keysB = Object.keys(b);
  if (keysA.length !== keysB.length) return false;
  return keysA.every((key) => keysB.includes(key) && isEqual(a[key], b[key]));
}
var Component = class {
  // Private fields for internal state management
  #cleanupFns = /* @__PURE__ */ new Set();
  // System state containers
  #state = {};
  #effects = /* @__PURE__ */ new Map();
  #eventBindings = /* @__PURE__ */ new Map();
  // DOM-related state
  #parts = {};
  #config = {};
  // Definitions (stored for observers and cleanup)
  #configDef = {};
  #partsDef = {};
  // Observers
  #partsObserver = null;
  #configObserver = null;
  // Component name for logging
  #componentName = null;
  // Add new private field for immediate effects
  #immediateEffects = /* @__PURE__ */ new Set();
  constructor(element) {
    if (!element || !(element instanceof Element)) {
      throw new Error("Component requires a DOM element");
    }
    this.element = element;
    this.#componentName = this.constructor.name;
    Logger.log(this.#componentName, "Initializing component");
    const setup = this.setup() || {};
    this.#initializeConfig(setup.config || {});
    this.#initializeParts(setup.parts || {});
    this.#initializeState(setup.state || {});
    this.#initializeEffects(setup.effects || {});
    this.#initializeBindings(setup.bindings || {});
    this.#observeConfig();
    queueMicrotask(() => this.#runImmediateEffects());
  }
  // Override this to define your component's structure
  setup() {
    return {
      state: {},
      // State with validation, computed props, watchers
      effects: {},
      // Side effects that respond to state
      parts: {},
      // DOM part definitions
      config: {},
      // Config from data-attributes
      bindings: {}
      // Event bindings
    };
  }
  // ---- Config System ----
  // The config system provides a way to configure components through data attributes.
  // It handles type conversion, validation, and live updates.
  #initializeConfig(configDef) {
    this.#configDef = configDef;
    for (const [key, def] of Object.entries(configDef)) {
      let value = this.#getConfigValue(key, def);
      Object.defineProperty(this.#config, key, {
        enumerable: true,
        get: () => value,
        set: (newValue) => {
          if (def.validate && !def.validate(newValue)) {
            Logger.log(this.#componentName, `Invalid config value for ${key}, falling back to default`);
            newValue = def.default;
          }
          const oldValue = value;
          value = newValue;
          if (oldValue !== newValue) {
            Logger.event(this.#componentName, "Config Changed", { key, from: oldValue, to: newValue });
            if (def.onChange) {
              def.onChange.call(this, newValue, oldValue);
            }
          }
        }
      });
    }
    Object.defineProperty(this, "config", {
      get: () => this.#config
    });
  }
  // Handles data attribute changes by converting them to config updates
  #observeConfig() {
    const attributesToWatch = Object.keys(this.#configDef).map((key) => `data-${toKebabCase(key)}`);
    this.#configObserver = new MutationObserver((mutations) => {
      const changes = {};
      for (const mutation of mutations) {
        if (mutation.type === "attributes" && mutation.attributeName) {
          const key = toCamelCase(mutation.attributeName.replace("data-", ""));
          const def = this.#configDef[key];
          if (def) {
            const newValue = this.#getConfigValue(key, def);
            const oldValue = this.#config[key];
            if (newValue !== oldValue) {
              changes[key] = {
                from: oldValue,
                to: newValue,
                attribute: mutation.attributeName,
                oldAttribute: mutation.oldValue
              };
              this.#config[key] = newValue;
              if (def.onChange) {
                def.onChange.call(this, newValue, oldValue);
              }
            }
          }
        }
      }
      if (Object.keys(changes).length > 0) {
        Logger.event(this.#componentName, "Config Attributes Changed", changes);
      }
    });
    this.#configObserver.observe(this.element, {
      attributes: true,
      attributeFilter: attributesToWatch,
      attributeOldValue: true
    });
    this.#cleanupFns.add(() => this.#configObserver.disconnect());
  }
  // Parses config values from data attributes with type conversion and validation
  #getConfigValue(key, def) {
    const attr = this.element.getAttribute(`data-${toKebabCase(key)}`);
    const currentValue = this.#config?.[key];
    if (attr === null || !def.type) return currentValue ?? def.default;
    try {
      const value = def.type === "boolean" ? attr !== "false" : def.type === "number" ? Number(attr) : def.type === "enum" && !def.values.includes(attr) ? currentValue ?? def.default : attr;
      return !def.validate || def.validate(value) ? value : currentValue ?? def.default;
    } catch (e) {
      console.warn(`Error parsing config value for ${key}:`, e);
      return currentValue ?? def.default;
    }
  }
  // ---- Parts System ----
  // The parts system manages references to DOM elements and collections.
  // It supports required parts, multiple elements, and dynamic updates.
  #initializeParts(partsDef) {
    this.#partsDef = partsDef;
    this.#parts.root = this.element;
    this.#updateParts();
    const hasChangeHandlers = Object.values(partsDef).some((def) => def.onChange);
    if (hasChangeHandlers) {
      this.#partsObserver = new MutationObserver(() => {
        const oldParts = { ...this.#parts };
        this.#updateParts();
        Object.entries(partsDef).forEach(([key, def]) => {
          if (def.onChange) {
            const oldValue = oldParts[key];
            const newValue = this.#parts[key];
            const changed = Array.isArray(oldValue) && Array.isArray(newValue) ? oldValue.length !== newValue.length || oldValue.some((el, i) => el !== newValue[i]) : oldValue !== newValue;
            if (changed) {
              Logger.event(this.#componentName, `Part Changed: ${key}`, {
                from: oldValue,
                to: newValue,
                selector: def.selector
              });
              def.onChange.call(this, newValue, oldValue);
            }
          }
        });
      });
      this.#partsObserver.observe(this.element, {
        childList: true,
        subtree: true,
        attributes: true,
        attributeFilter: ["data-part"]
      });
      Logger.log(this.#componentName, "Parts observer initialized", {
        observedParts: Object.keys(partsDef),
        config: { childList: true, subtree: true, attributes: true }
      });
      this.#cleanupFns.add(() => this.#partsObserver?.disconnect());
    }
    Object.defineProperty(this, "parts", { get: () => this.#parts });
  }
  #updateParts() {
    this.#parts.root = this.element;
    Object.entries(this.#partsDef).forEach(([key, def]) => {
      if (key === "root") {
        console.warn("Cannot override root part. It will always point to the component element.");
        return;
      }
      const elements = this.element.querySelectorAll(def.selector);
      if (def.required && (!elements || elements.length === 0)) {
        Logger.event(this.#componentName, `Required part "${key}" not found`, {
          selector: def.selector,
          required: true
        });
        throw new Error(`Required part "${key}" not found`);
      }
      const newValue = def.multiple ? Array.from(elements) : elements[0] || null;
      this.#parts[key] = newValue;
    });
  }
  // ---- State System ----
  // The state system provides reactive state management with validation,
  // computed properties, and change notifications.
  #initializeState(stateDef) {
    const stateValues = {};
    Object.entries(stateDef).forEach(([key, def]) => {
      const initValue = def.init ? def.init.call(this) : void 0;
      stateValues[key] = initValue ?? def.default;
      this.#state[key] = /* @__PURE__ */ new Set();
    });
    const state = new Proxy(stateValues, {
      get: (target, prop) => target[prop],
      set: (target, prop, value) => {
        const def = stateDef[prop];
        if (def?.validate && !def.validate(value)) {
          Logger.log(this.#componentName, `Invalid state value for ${prop}`);
          return true;
        }
        const oldValue = target[prop];
        if (isEqual(oldValue, value)) {
          return true;
        }
        target[prop] = value;
        Logger.state(this.#componentName, { [prop]: oldValue }, { [prop]: value });
        def?.onChange?.call(this, value, oldValue);
        this.#state[prop]?.forEach((effect) => {
          const context = {
            config: this.#config,
            state: this.state,
            parts: this.#parts,
            oldState: { [prop]: oldValue }
          };
          if (!effect.def.when || effect.def.when.call(this, context)) {
            effect.run();
          }
        });
        return true;
      }
    });
    Object.defineProperty(this, "state", { get: () => state });
  }
  // ---- Effects System ----
  // The effects system manages side effects that respond to state changes.
  // Effects can have cleanup functions and can be immediate or state-dependent.
  #cleanupEffect = (key) => {
    const cleanupFns = this.#effects.get(key)?.cleanupFns || [];
    cleanupFns.forEach((fn) => fn());
    this.#effects.set(key, { cleanupFns: [] });
  };
  #initializeEffects(effectsDef) {
    const createEffect = (key, def) => ({
      key,
      def,
      run: () => {
        const stateValues = def.observe?.reduce((acc, key2) => ({ ...acc, [key2]: this.state[key2] }), {});
        const context = {
          config: this.#config,
          state: this.state,
          parts: this.#parts,
          oldState: stateValues
        };
        if (def.when && !def.when.call(this, context)) {
          this.#cleanupEffect(key);
          return;
        }
        Logger.event(this.#componentName, `Effect Run: ${key}`, { observing: def.observe, stateValues });
        this.#cleanupEffect(key);
        const result = def.run.call(this, context.oldState);
        if (result) {
          const cleanupFns = Array.isArray(result) ? result : [result];
          if (cleanupFns.every((fn) => typeof fn === "function")) {
            this.#effects.set(key, { cleanupFns });
          }
        }
      }
    });
    const processEffect = (key, def) => {
      if (!def.immediate && (!Array.isArray(def.observe) || def.observe.length === 0)) {
        throw new Error(`Effect ${key} must observe at least one state property or be immediate`);
      }
      const effect = createEffect(key, def);
      this.#effects.set(key, { ...effect, cleanupFns: [] });
      if (def.immediate) {
        this.#immediateEffects.add(effect);
      } else {
        def.observe?.forEach((stateKey) => {
          if (!this.#state[stateKey]) {
            this.#state[stateKey] = /* @__PURE__ */ new Set();
          }
          this.#state[stateKey].add(effect);
        });
      }
    };
    Object.entries(effectsDef).forEach(([key, def]) => processEffect(key, def));
  }
  #runImmediateEffects() {
    for (const effect of this.#immediateEffects) {
      const context = {
        config: this.#config,
        state: this.state,
        parts: this.#parts,
        oldState: {}
      };
      if (effect.def.when && !effect.def.when.call(this, context)) {
        continue;
      }
      effect.run();
    }
    this.#immediateEffects.clear();
  }
  // ---- Event Binding System ----
  // The binding system provides declarative event handling with automatic cleanup.
  // It supports delegation, multiple targets, and effect-scoped bindings.
  #initializeBindings(bindingsDef) {
    const cleanups = [];
    for (const [targetKey, events] of Object.entries(bindingsDef)) {
      let target = targetKey === "window" ? window : targetKey === "document" ? document : this.parts[targetKey];
      if (!target) {
        continue;
      }
      for (const [event2, config] of Object.entries(events)) {
        const { handler, options = {}, delegate } = this.#normalizeConfig(config);
        const boundHandler = delegate ? (e) => {
          const delegateTarget = e.target.closest(delegate);
          if (delegateTarget && target.contains(delegateTarget)) {
            handler.call(this, e, delegateTarget);
          }
        } : handler.bind(this);
        const targets = Array.isArray(target) ? target : [target];
        targets.forEach((t) => {
          t.addEventListener(event2, boundHandler, options);
          cleanups.push(() => t.removeEventListener(event2, boundHandler, options));
        });
      }
    }
    if (cleanups.length > 0) {
      this.#cleanupFns.add(() => cleanups.forEach((cleanup) => cleanup()));
    }
  }
  // Helper for effect-scoped event binding
  bind(target, event2, handler, options = {}) {
    if (typeof target === "string") {
      target = this.parts[target];
      if (!target) {
        console.warn(`Part "${target}" not found for binding`);
        return () => {
        };
      }
    }
    if (!target) return () => {
    };
    const boundHandler = handler.bind(this);
    const targets = Array.isArray(target) ? target : [target];
    const cleanups = [];
    targets.forEach((t) => {
      t.addEventListener(event2, boundHandler, options);
      cleanups.push(() => t.removeEventListener(event2, boundHandler, options));
    });
    return () => cleanups.forEach((cleanup) => cleanup());
  }
  #normalizeConfig(config) {
    if (typeof config === "function") {
      return { handler: config };
    }
    return config;
  }
  // ---- DOM Helpers ----
  // Helper to update element attributes and classes
  updateAttributes(element, attributes) {
    if (!element) return;
    for (const [attr, value] of Object.entries(attributes)) {
      if (attr === "class" && typeof value === "object") {
        Object.entries(value).forEach(([className, active]) => element.classList.toggle(className, active));
      } else if (value === false) {
        element.removeAttribute(attr);
      } else {
        element.setAttribute(attr, value === true ? "" : value);
      }
    }
  }
  // ---- Lifecycle ----
  destroy() {
    Logger.log(this.#componentName, "Destroying component");
    this.#cleanupFns.forEach((fn) => fn());
    this.#cleanupFns.clear();
    this.#effects.forEach((effect) => {
      const cleanupFns = effect.cleanupFns || [];
      cleanupFns.forEach((fn) => fn());
    });
    this.#effects.clear();
    this.#state = {};
    Logger.log(this.#componentName, "Component destroyed");
  }
  // Developer Experience Helpers
  debug() {
    Logger.log(this.#componentName, "Component Debug Info", {
      element: this.element,
      state: { ...this.state },
      config: { ...this.#config },
      parts: { ...this.#parts },
      effects: Array.from(this.#effects.keys()),
      bindings: Array.from(this.#eventBindings.keys()),
      observers: {
        config: this.#configObserver ? "active" : "inactive",
        parts: this.#partsObserver ? "active" : "inactive"
      }
    });
  }
};
var component_default = Component;

// js/components/utils/datetime.js
var import_dayjs = __toESM(require_dayjs_min(), 1);
var import_utc = __toESM(require_utc(), 1);
var import_timezone = __toESM(require_timezone(), 1);
import_dayjs.default.extend(import_utc.default);
import_dayjs.default.extend(import_timezone.default);
var STRFTIME_TO_DAYJS = /* @__PURE__ */ new Map([
  // Date
  ["%Y", "YYYY"],
  // Year with century (2024)
  ["%y", "YY"],
  // Year without century (24)
  ["%m", "MM"],
  // Month with leading zero (01-12)
  ["%-m", "M"],
  // Month without leading zero (1-12)
  ["%d", "DD"],
  // Day with leading zero (01-31)
  ["%-d", "D"],
  // Day without leading zero (1-31)
  ["%j", "DDDD"],
  // Day of year (001-366)
  ["%u", "E"],
  // Day of week, Monday is 1 (1-7)
  // Weekday names
  ["%A", "dddd"],
  // Full weekday name (Monday)
  ["%a", "ddd"],
  // Abbreviated weekday name (Mon)
  // Month names
  ["%B", "MMMM"],
  // Full month name (January)
  ["%b", "MMM"],
  // Abbreviated month name (Jan)
  // Time
  ["%H", "HH"],
  // Hour using 24-hour clock (00-23)
  ["%-H", "H"],
  // Hour using 24-hour clock without leading zero (0-23)
  ["%I", "hh"],
  // Hour using 12-hour clock (01-12)
  ["%-I", "h"],
  // Hour using 12-hour clock without leading zero (1-12)
  ["%M", "mm"],
  // Minute with leading zero (00-59)
  ["%-M", "m"],
  // Minute without leading zero (0-59)
  ["%S", "ss"],
  // Second with leading zero (00-59)
  ["%-S", "s"],
  // Second without leading zero (0-59)
  ["%f", "SSS"],
  // Microseconds (000000-999999)
  ["%p", "A"],
  // AM/PM uppercase
  ["%P", "a"],
  // am/pm lowercase
  // Time zone
  ["%z", "ZZ"],
  // UTC offset (+0300, -0530)
  ["%Z", "z"],
  // Time zone abbreviation (CET, BRST)
  // Combined formats
  ["%c", "YYYY-MM-DD HH:mm:ss"],
  // Preferred date+time representation
  ["%x", "YYYY-MM-DD"],
  // Preferred date representation
  ["%X", "HH:mm:ss"],
  // Preferred time representation
  // Special
  ["%%", "%"]
  // Literal % character
]);
var STRFTIME_PATTERNS = Array.from(STRFTIME_TO_DAYJS.keys()).sort((a, b) => b.length - a.length);
var STRFTIME_REGEX = new RegExp(
  STRFTIME_PATTERNS.map((pattern) => pattern.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")).join("|"),
  "g"
);
var DAYJS_TOKENS_REGEX = /[YQMDWwdHhmsaAZz]/g;
function strftimeToDayjs(format) {
  if (typeof format !== "string") {
    throw new TypeError("Format must be a string");
  }
  if (!format) return "";
  const parts = [];
  let lastIndex = 0;
  let match;
  while ((match = STRFTIME_REGEX.exec(format)) !== null) {
    if (match.index > lastIndex) {
      parts.push({ type: "text", value: format.slice(lastIndex, match.index) });
    }
    parts.push({ type: "token", value: match[0] });
    lastIndex = STRFTIME_REGEX.lastIndex;
  }
  if (lastIndex < format.length) {
    parts.push({ type: "text", value: format.slice(lastIndex) });
  }
  return parts.map((part) => {
    if (part.type === "token") {
      return STRFTIME_TO_DAYJS.get(part.value) || part.value;
    } else {
      return part.value.replace(DAYJS_TOKENS_REGEX, "[$&]");
    }
  }).join("");
}
function parseDate(dateString, format = "YYYY-MM-DD") {
  if (!dateString) return null;
  let date;
  if (format) {
    date = import_dayjs.default.utc(dateString, format);
  } else {
    date = import_dayjs.default.utc(dateString);
  }
  return date.isValid() ? date : null;
}
function formatStrftimeDate(date, strftimeFormat, options = {}) {
  if (!date) return null;
  let formattingDate = date;
  if (options.timezone === "local") {
    formattingDate = date.local();
  } else if (options.timezone && options.timezone !== "utc") {
    formattingDate = date.tz(options.timezone);
  } else {
    formattingDate = date.utc();
  }
  const dayjsFormat = strftimeToDayjs(strftimeFormat);
  return formattingDate.format(dayjsFormat);
}

// js/components/date_picker/position.js
var Position4 = class {
  constructor(parts) {
    this.parts = parts;
    this.cleanup = null;
  }
  setup() {
    const updatePosition = () => {
      computePosition2(this.parts.toggle, this.parts.wrapper, {
        placement: "bottom-start",
        strategy: "fixed",
        middleware: [offset2(5), flip2(), shift2({ padding: 10 })]
      }).then(({ x, y }) => {
        Object.assign(this.parts.wrapper.style, {
          left: `${x}px`,
          top: `${y}px`,
          width: "max-content"
        });
      });
    };
    updatePosition();
    this.cleanup = autoUpdate(this.parts.toggle, this.parts.wrapper, updatePosition);
    window.addEventListener("resize", updatePosition);
    const originalCleanup = this.cleanup;
    this.cleanup = () => {
      originalCleanup();
      window.removeEventListener("resize", updatePosition);
    };
  }
  destroy() {
    if (this.cleanup) {
      this.cleanup();
      this.cleanup = null;
    }
  }
};

// js/components/date_picker/date_picker.js
var import_dayjs2 = __toESM(require_dayjs_min(), 1);
var import_utc2 = __toESM(require_utc(), 1);
var import_isoWeek = __toESM(require_isoWeek(), 1);
import_dayjs2.default.extend(import_utc2.default);
import_dayjs2.default.extend(import_isoWeek.default);
var DatePicker = class extends component_default {
  static name = "DatePicker";
  // Private fields for disabled dates (categorized for O(1) lookup)
  #disabledDatesSet = null;
  // Set of ISO date strings
  #disabledDays = null;
  // Set of day names (e.g., "weekends", "weekdays")
  #disabledMonths = null;
  // Set of month numbers
  #disabledYears = null;
  // Set of year numbers
  #disabledDaysOfMonth = null;
  // Set of day-of-month numbers (1-31)
  #disabledWeeks = null;
  // Set of ISO week numbers (1-53)
  #disabledMonthDays = null;
  // Set of "M:D" strings (e.g., "12:25")
  #disabledWeekdays = null;
  // Set of weekday numbers (1=Mon, 7=Sun)
  constructor(element) {
    super(element);
    this.animator = new Animator();
  }
  // Initialize and categorize disabled dates for efficient lookup
  #initializeDisabledDates() {
    const { disabledDates } = this.config;
    this.#disabledDatesSet = null;
    this.#disabledDays = null;
    this.#disabledMonths = null;
    this.#disabledYears = null;
    this.#disabledDaysOfMonth = null;
    this.#disabledWeeks = null;
    this.#disabledMonthDays = null;
    this.#disabledWeekdays = null;
    if (!disabledDates) return;
    try {
      const items = JSON.parse(disabledDates);
      const dates = [];
      const days = [];
      const months = [];
      const years = [];
      const daysOfMonth = [];
      const weeks = [];
      const monthDays = [];
      const weekdays = [];
      for (const item of items) {
        if (item.startsWith("month:")) {
          months.push(parseInt(item.slice(6)));
        } else if (item.startsWith("year:")) {
          years.push(parseInt(item.slice(5)));
        } else if (item.startsWith("day:")) {
          daysOfMonth.push(parseInt(item.slice(4)));
        } else if (item.startsWith("week:")) {
          weeks.push(parseInt(item.slice(5)));
        } else if (item.startsWith("month_day:")) {
          const parts = item.split(":");
          monthDays.push(`${parts[1]}:${parts[2]}`);
        } else if (item.startsWith("weekday:")) {
          weekdays.push(parseInt(item.slice(8)));
        } else if (item.match(/^\d{4}-\d{2}-\d{2}$/)) {
          dates.push(item);
        } else {
          days.push(item);
        }
      }
      this.#disabledDatesSet = dates.length > 0 ? new Set(dates) : null;
      this.#disabledDays = days.length > 0 ? new Set(days) : null;
      this.#disabledMonths = months.length > 0 ? new Set(months) : null;
      this.#disabledYears = years.length > 0 ? new Set(years) : null;
      this.#disabledDaysOfMonth = daysOfMonth.length > 0 ? new Set(daysOfMonth) : null;
      this.#disabledWeeks = weeks.length > 0 ? new Set(weeks) : null;
      this.#disabledMonthDays = monthDays.length > 0 ? new Set(monthDays) : null;
      this.#disabledWeekdays = weekdays.length > 0 ? new Set(weekdays) : null;
    } catch (e) {
    }
  }
  // Check if a date matches any disabled pattern
  #matchesDisabledPattern(date) {
    const dayOfWeek = date.day();
    const isoWeekday = dayOfWeek === 0 ? 7 : dayOfWeek;
    const month = date.month() + 1;
    const year = date.year();
    const dayOfMonth = date.date();
    const isoWeek2 = date.isoWeek();
    if (this.#disabledMonths?.has(month)) return true;
    if (this.#disabledYears?.has(year)) return true;
    if (this.#disabledDaysOfMonth?.has(dayOfMonth)) return true;
    if (this.#disabledWeeks?.has(isoWeek2)) return true;
    if (this.#disabledMonthDays?.has(`${month}:${dayOfMonth}`)) return true;
    if (this.#disabledWeekdays?.has(isoWeekday)) return true;
    if (this.#disabledDays) {
      if (this.#disabledDays.has("weekends") && (dayOfWeek === 0 || dayOfWeek === 6)) return true;
      if (this.#disabledDays.has("weekdays") && dayOfWeek >= 1 && dayOfWeek <= 5) return true;
    }
    return false;
  }
  // Find the next enabled date in a given direction
  #findNextEnabledDate(startDate, direction, granularity) {
    let current = startDate;
    const maxAttempts = 100;
    let attempts = 0;
    const isDisabledFn = this.#isYearMode() ? this.#isYearDisabled.bind(this) : this.#isMonthMode() ? this.#isMonthDisabled.bind(this) : this.#isDateDisabled.bind(this);
    while (attempts < maxAttempts) {
      current = direction > 0 ? current.add(Math.abs(direction), granularity) : current.subtract(Math.abs(direction), granularity);
      attempts++;
      if (!isDisabledFn(current)) {
        return current;
      }
    }
    return null;
  }
  setup() {
    return {
      // Define the DOM structure
      parts: {
        toggle: { selector: '[data-part="toggle"]', required: false },
        toggleText: { selector: '[data-part="toggle-text"]', required: false },
        input: { selector: '[data-part="input"]', required: false },
        inputStart: { selector: '[data-part="input-start"]', required: false },
        inputEnd: { selector: '[data-part="input-end"]', required: false },
        wrapper: { selector: '[data-part="wrapper"]', required: true },
        currentMonthTitle: { selector: '[data-part="current-month-title"]', required: false },
        calendar: { selector: '[data-part="calendar"]', required: true },
        weekdays: { selector: '[data-part="weekdays"]', required: true },
        prevMonthButton: { selector: '[data-part="prev-month"]', required: true },
        nextMonthButton: { selector: '[data-part="next-month"]', required: true },
        prevYearButton: { selector: '[data-part="prev-year"]', required: false },
        nextYearButton: { selector: '[data-part="next-year"]', required: false },
        yearSelect: { selector: '[data-part="year-select"]', required: false },
        monthSelect: { selector: '[data-part="month-select"]', required: false },
        dayTemplate: { selector: '[data-part="day-template"]', required: true },
        hourInput: { selector: '[data-part="hour-input"]', required: false },
        minuteInput: { selector: '[data-part="minute-input"]', required: false },
        secondInput: { selector: '[data-part="second-input"]', required: false },
        cancelButton: { selector: '[data-part="cancel-button"]', required: false },
        applyButton: { selector: '[data-part="apply-button"]', required: false },
        amPmSelect: { selector: '[data-part="am-pm-select"]', required: false }
      },
      // Define component configuration
      config: {
        min: { type: "string", default: null },
        max: { type: "string", default: null },
        disabledDates: {
          type: "string",
          default: null,
          onChange: function() {
            this.#initializeDisabledDates();
            if (this.state.isOpen) {
              this.#renderCalendar();
            }
          }
        },
        displayFormat: { type: "string", default: "%b %-d, %Y" },
        weekStart: { type: "number", default: 0 },
        // 0 = Sunday, 1 = Monday, etc.
        range: { type: "boolean", default: false },
        inline: { type: "boolean", default: false },
        multiple: { type: "boolean", default: false },
        // Enable multiple date selection
        timePicker: { type: "boolean", default: false },
        // Enable time picker
        close: { type: "enum", values: ["auto", "manual", "confirm"], default: "auto" },
        timeFormat: { type: "enum", values: ["12", "24"], default: "12" },
        granularity: { type: "enum", values: ["day", "month", "year"], default: "day" }
      },
      // Define component state
      state: {
        isOpen: { default: false, init: () => this.config.inline },
        pickedDate: { default: null },
        currentDate: { default: null },
        focusedDate: { default: null },
        selection: {
          default: { current: [], pending: null },
          init: () => {
            let current = [];
            if (this.config.range) {
              const start = parseDate(this.parts.inputStart?.value);
              const end = parseDate(this.parts.inputEnd?.value);
              current = [start, end].filter(Boolean);
            } else if (this.config.multiple) {
              const inputs = Array.from(this.parts.root.querySelectorAll('[data-part="input"]'));
              current = inputs.map((input) => parseDate(input.value)).filter(Boolean);
            } else {
              const date = parseDate(this.parts.input?.value);
              current = date ? [date] : [];
            }
            return {
              current,
              pending: null
            };
          }
        }
      },
      // Define event bindings
      bindings: {
        toggle: {
          click: (e) => this.#onToggleClick(e),
          keydown: (e) => this.#onToggleKeyDown(e),
          blur: (e) => this.#onToggleBlur(e)
        },
        prevMonthButton: {
          click: (e) => this.#onPrevMonthClick(e)
        },
        nextMonthButton: {
          click: (e) => this.#onNextMonthClick(e)
        },
        prevYearButton: {
          click: (e) => this.#onPrevYearClick(e)
        },
        nextYearButton: {
          click: (e) => this.#onNextYearClick(e)
        },
        yearSelect: {
          input: (e) => this.#onYearSelectChange(e),
          change: (e) => {
            e.preventDefault();
            e.stopPropagation();
          }
        },
        monthSelect: {
          input: (e) => this.#onMonthSelectChange(e),
          change: (e) => {
            e.preventDefault();
            e.stopPropagation();
          }
        },
        calendar: {
          click: { handler: (e) => this.#onDayClick(e), delegate: "button[data-date]" },
          keydown: { handler: (e) => this.#onDayKeyDown(e), delegate: "button[data-date]" }
        },
        hourInput: {
          keydown: (e) => this.#onTimeKeyDown(e, "hour")
        },
        minuteInput: {
          keydown: (e) => this.#onTimeKeyDown(e, "minute")
        },
        secondInput: {
          keydown: (e) => this.#onTimeKeyDown(e, "second")
        },
        amPmSelect: {
          change: (e) => {
            e.preventDefault();
            e.stopPropagation();
            this.#onAmPmSelectChange(e);
          },
          input: (e) => {
            e.preventDefault();
            e.stopPropagation();
          },
          keydown: (e) => this.#onAmPmSelectChange(e)
        },
        cancelButton: {
          click: (e) => this.#onCancelButtonClick(e)
        },
        applyButton: {
          click: (e) => this.#onApplyButtonClick(e)
        }
      },
      // Define effects
      effects: {
        setGranularityAttribute: {
          immediate: true,
          run: () => {
            this.parts.root.setAttribute("data-granularity", this.config.granularity);
          }
        },
        initializeDisabledDates: {
          immediate: true,
          run: () => this.#initializeDisabledDates()
        },
        initializeCurrentDate: {
          immediate: true,
          when: () => this.config.inline,
          run: () => this.state.currentDate = this.#findInitialDate()
        },
        visibility: {
          observe: ["isOpen"],
          when: ({ config }) => !config.inline,
          run: ({ isOpen }) => this.#onVisibilityChange({ isOpen })
        },
        handleSingleDatePick: {
          observe: ["pickedDate"],
          when: () => this.#isSingleMode(),
          run: ({ pickedDate }) => {
            if (!pickedDate) return;
            pickedDate = this.#normalizeToGranularity(pickedDate);
            const workingSelection = this.#getWorkingSelection();
            const granularity = this.#getGranularityUnit();
            const existingDate = workingSelection.find((date) => date?.isSame(pickedDate, granularity));
            if (existingDate) {
              this.#updateSelection([], { isPending: this.#shouldUsePendingSelection() });
              return;
            }
            if (this.#isDayMode()) {
              const currentSelection = workingSelection[0];
              if (currentSelection) {
                pickedDate = this.#copyTimeFromDate(pickedDate, currentSelection);
              }
            }
            this.#updateSelection([pickedDate], { isPending: this.#shouldUsePendingSelection() });
          }
        },
        handleMultipleDatePick: {
          observe: ["pickedDate"],
          when: () => this.#isMultipleMode(),
          run: ({ pickedDate }) => {
            if (!pickedDate) return;
            pickedDate = this.#normalizeToGranularity(pickedDate);
            const baseSelection = this.#getWorkingSelection();
            const newSelection = this.#toggleDateInSelection(pickedDate, baseSelection);
            this.#updateSelection(newSelection, { isPending: this.#shouldUsePendingSelection() });
          }
        },
        handleRangeDatePick: {
          observe: ["pickedDate"],
          when: () => this.#isRangeMode(),
          run: ({ pickedDate }) => {
            if (!pickedDate) return;
            pickedDate = this.#normalizeToGranularity(pickedDate);
            const baseSelection = this.#getWorkingSelection();
            const newSelection = this.#getNewRangeSelection(pickedDate, baseSelection);
            this.#updateSelection(newSelection, { isPending: this.#shouldUsePendingSelection() });
          }
        },
        handleClosing: {
          observe: ["selection"],
          run: () => {
            if (this.#getEffectiveCloseMode() !== "auto") return;
            const shouldClose = this.#shouldClose();
            if (shouldClose) {
              this.#close();
            }
          }
        },
        syncInputs: {
          observe: ["selection"],
          when: ({ state: { selection } }) => !selection.pending,
          run: ({ selection }) => {
            this.#syncInputValues(selection.current);
          }
        },
        // UI Updates
        updateApplyButton: {
          observe: ["selection"],
          when: () => this.#isConfirmMode(),
          run: ({ selection }) => {
            const canApply = this.#canApplySelection(selection);
            this.parts.applyButton.disabled = !canApply;
          }
        },
        renderCalendar: {
          observe: ["currentDate", "focusedDate", "selection"],
          when: ({ state }) => state.isOpen,
          run: () => this.#renderCalendar()
        },
        renderTimepicker: {
          observe: ["currentDate", "selection"],
          when: () => this.#hasTimePicker() && this.state.isOpen,
          run: () => this.#renderTimepicker()
        },
        updateToggleDisplay: {
          observe: ["selection"],
          run: ({ selection }) => {
            if (this.config.inline) return;
            this.parts.toggleText.textContent = this.#formatSelectionDisplay(selection.current);
          }
        },
        // Interaction Management
        manageFocus: {
          observe: ["focusedDate"],
          run: ({ focusedDate }) => {
            if (!focusedDate) return;
            const dayButton = this.parts.calendar.querySelector(`[data-date="${focusedDate.format("YYYY-MM-DD")}"]`);
            if (dayButton) dayButton.focus();
          }
        },
        clearPickedDate: {
          observe: ["pickedDate"],
          when: () => this.state.pickedDate,
          run: () => {
            this.state.pickedDate = null;
          }
        }
      }
    };
  }
  // Additional helper methods
  #hasTimePicker() {
    return this.config.timePicker && this.#isDayMode();
  }
  #getEffectiveCloseMode() {
    if ((this.config.timePicker || this.config.multiple || this.config.range) && this.config.close === "auto") {
      return "manual";
    }
    return this.config.close;
  }
  #shouldUsePendingSelection() {
    return this.#getEffectiveCloseMode() === "confirm";
  }
  #shouldClose() {
    if (this.#isRangeMode()) {
      return this.state.selection.current.length === 2;
    }
    if (this.#isSingleMode()) {
      return this.state.pickedDate != null;
    }
    return false;
  }
  #syncInputValues(dates, format = "YYYY-MM-DD") {
    const utcDates = dates.map((date) => date ? date.utc() : null);
    const effectiveFormat = this.#hasTimePicker() ? "YYYY-MM-DD HH:mm:ss" : format;
    if (this.#isRangeMode()) {
      const [start, end] = utcDates;
      this.#updateInputValue(this.parts.inputStart, start, effectiveFormat);
      this.#updateInputValue(this.parts.inputEnd, end, effectiveFormat);
      return;
    }
    if (this.#isMultipleMode()) {
      this.#syncMultipleInputValues(utcDates, effectiveFormat);
      return;
    }
    this.#updateInputValue(this.parts.input, utcDates[0], effectiveFormat);
    if (this.#hasTimePicker()) {
      this.#updateTimeInputs(utcDates[0]);
    }
  }
  #updateInputValue(input, date, format, { emitChange = true } = {}) {
    if (!input) return;
    const newValue = date ? date.utc().format(format) : "";
    if (input.value !== newValue) {
      input.value = newValue;
      if (emitChange) {
        this.#dispatchChangeEvent(input);
      }
    }
  }
  #syncMultipleInputValues(dates, format) {
    const inputWrapper = this.parts.input.parentNode;
    const existingInputs = Array.from(inputWrapper.querySelectorAll('[data-part="input"]'));
    const firstInput = this.parts.input;
    let valueChanged = false;
    if (existingInputs.length === 0) {
      inputWrapper.appendChild(firstInput);
      valueChanged = firstInput.value !== "";
      firstInput.value = "";
    }
    if (dates.length === 0) {
      if (existingInputs.length > 1) {
        existingInputs.slice(1).forEach((input) => input.remove());
        valueChanged = true;
      }
      if (firstInput.value !== "") {
        firstInput.value = "";
        valueChanged = true;
      }
    } else {
      if (existingInputs.length > Math.max(dates.length, 1)) {
        valueChanged = true;
      }
      dates.forEach((date, index) => {
        const formattedValue = date ? date.format(format) : "";
        let input = existingInputs[index];
        if (!input) {
          input = firstInput.cloneNode(true);
          input.value = "";
          inputWrapper.appendChild(input);
          valueChanged = true;
        }
        if (input.value !== formattedValue) {
          input.value = formattedValue;
          valueChanged = true;
        }
      });
      const inputsToRemove = existingInputs.slice(Math.max(dates.length, 1));
      inputsToRemove.forEach((input) => input.remove());
    }
    if (valueChanged) {
      this.#dispatchChangeEvent(firstInput);
    }
  }
  #updateDateTimeValue(date, type, value) {
    if (!date) return null;
    switch (type) {
      case "hour":
        return date.hour(value);
      case "minute":
        return date.minute(value);
      case "second":
        return date.second(value);
      default:
        return date;
    }
  }
  #dispatchChangeEvent(input) {
    input.dispatchEvent(new Event("change", { bubbles: true }));
  }
  #updateSelection(newDates, { isPending = false } = {}) {
    this.state.selection = {
      current: isPending ? this.state.selection.current : newDates,
      pending: isPending ? newDates : null
      // Always clear pending when updating current
    };
  }
  #getWorkingSelection() {
    return this.#shouldUsePendingSelection() ? this.state.selection.pending || [...this.state.selection.current] : this.state.selection.current;
  }
  #toggleDateInSelection(pickedDate, baseSelection = []) {
    const granularity = this.#getGranularityUnit();
    const existingIndex = baseSelection.findIndex((date) => date?.isSame(pickedDate, granularity));
    if (existingIndex >= 0) {
      return [...baseSelection.slice(0, existingIndex), ...baseSelection.slice(existingIndex + 1)];
    }
    return [...baseSelection, pickedDate];
  }
  #canApplySelection(selection) {
    if (!selection.pending) return false;
    if (this.#isRangeMode()) {
      const hasBothDates = selection.pending.length === 2;
      const isClearingRange = selection.pending.length === 0 && selection.current.length > 0;
      const matchesCurrentSelection = this.#areSelectionsEqual(selection.pending, selection.current);
      return (hasBothDates || isClearingRange) && !matchesCurrentSelection;
    }
    return !this.#areSelectionsEqual(selection.pending, selection.current);
  }
  #areSelectionsEqual(sel1, sel2) {
    if (!sel1 || !sel2) return false;
    if (sel1.length !== sel2.length) return false;
    return sel1.every((date, i) => date?.isSame(sel2[i]));
  }
  #formatSelectionDisplay(selection) {
    const displayFormat = this.#getEffectiveDisplayFormat();
    if (this.#isRangeMode()) {
      const [start, end] = selection;
      if (!start) return "";
      if (!end) return formatStrftimeDate(start.utc(), displayFormat);
      return `${formatStrftimeDate(start.utc(), displayFormat)} - ${formatStrftimeDate(end.utc(), displayFormat)}`;
    }
    if (this.#isMultipleMode()) {
      if (selection.length === 0) return "";
      if (selection.length === 1) return formatStrftimeDate(selection[0].utc(), displayFormat);
      return `${selection.length} dates selected`;
    }
    const [date] = selection;
    return date ? formatStrftimeDate(date.utc(), displayFormat) : "";
  }
  // Helper methods
  #isSingleMode() {
    return !this.config.range && !this.config.multiple;
  }
  #isMultipleMode() {
    return !this.config.range && this.config.multiple;
  }
  #isRangeMode() {
    return this.config.range && !this.config.multiple;
  }
  #isConfirmMode() {
    return this.#getEffectiveCloseMode() === "confirm";
  }
  #isDayMode() {
    return this.config.granularity === "day";
  }
  #isMonthMode() {
    return this.config.granularity === "month";
  }
  #isYearMode() {
    return this.config.granularity === "year";
  }
  #getGranularityUnit() {
    return this.config.granularity;
  }
  #normalizeToGranularity(date) {
    if (!date) return date;
    if (this.#isMonthMode()) {
      return date.startOf("month");
    } else if (this.#isYearMode()) {
      return date.startOf("year");
    }
    return date;
  }
  #getEffectiveDisplayFormat() {
    if (this.#isMonthMode()) {
      return "%b %Y";
    } else if (this.#isYearMode()) {
      return "%Y";
    }
    return this.config.displayFormat;
  }
  #copyTimeFromDate(targetDate, sourceDate) {
    return targetDate.hour(sourceDate.hour()).minute(sourceDate.minute()).second(sourceDate.second());
  }
  // Check if date is outside min/max bounds (for navigation blocking)
  #isDateOutsideBounds(date) {
    const { min: min2, max: max2 } = this.config;
    const minDate = min2 ? parseDate(min2) : null;
    const maxDate = max2 ? parseDate(max2) : null;
    return minDate && date.isBefore(minDate, "day") || maxDate && date.isAfter(maxDate, "day");
  }
  // Check if date is disabled (for date button disabling)
  #isDateDisabled(date) {
    if (this.#isDateOutsideBounds(date)) {
      return true;
    }
    if (this.#disabledDatesSet?.has(date.format("YYYY-MM-DD"))) {
      return true;
    }
    if (this.#matchesDisabledPattern(date)) {
      return true;
    }
    return false;
  }
  #isDateSelected(date) {
    const selection = this.state.selection.pending || this.state.selection.current;
    return selection.some((selectedDate) => selectedDate?.isSame(date, "day"));
  }
  #isMonthDisabled(date) {
    const { min: min2, max: max2 } = this.config;
    const minDate = min2 ? parseDate(min2) : null;
    const maxDate = max2 ? parseDate(max2) : null;
    const monthStart = date.startOf("month");
    const monthEnd = date.endOf("month");
    if (minDate && monthEnd.isBefore(minDate, "day") || maxDate && monthStart.isAfter(maxDate, "day")) {
      return true;
    }
    if (this.#disabledDatesSet || this.#disabledDays || this.#disabledMonths || this.#disabledYears || this.#disabledDaysOfMonth || this.#disabledWeeks || this.#disabledMonthDays || this.#disabledWeekdays) {
      let current = monthStart;
      let allDisabled = true;
      while (current.isBefore(monthEnd, "day") || current.isSame(monthEnd, "day")) {
        if (!this.#isDateDisabled(current)) {
          allDisabled = false;
          break;
        }
        current = current.add(1, "day");
      }
      if (allDisabled) return true;
    }
    return false;
  }
  #isMonthSelected(date) {
    const selection = this.state.selection.pending || this.state.selection.current;
    return selection.some((selectedDate) => selectedDate?.isSame(date, "month"));
  }
  #isYearDisabled(date) {
    const { min: min2, max: max2 } = this.config;
    const minDate = min2 ? parseDate(min2) : null;
    const maxDate = max2 ? parseDate(max2) : null;
    const yearStart = date.startOf("year");
    const yearEnd = date.endOf("year");
    if (minDate && yearEnd.isBefore(minDate, "day") || maxDate && yearStart.isAfter(maxDate, "day")) {
      return true;
    }
    if (this.#disabledDatesSet || this.#disabledDays || this.#disabledMonths || this.#disabledYears || this.#disabledDaysOfMonth || this.#disabledWeeks || this.#disabledMonthDays || this.#disabledWeekdays) {
      for (let month = 0; month < 12; month++) {
        const testDate = yearStart.month(month).startOf("month");
        if (!this.#isMonthDisabled(testDate)) {
          return false;
        }
      }
      return true;
    }
    return false;
  }
  #isYearSelected(date) {
    const selection = this.state.selection.pending || this.state.selection.current;
    return selection.some((selectedDate) => selectedDate?.isSame(date, "year"));
  }
  // Handles edge cases where the calendar might open in a month with all disabled dates.
  // This happens when a date is selected outside min/max bounds (e.g., March selected but
  // only January dates are valid). In such cases, we find the closest valid date to show.
  // In range mode, we prioritize the start date over the selected date.
  #findInitialDate() {
    const initialDate = this.state.selection.current[0] || (0, import_dayjs2.default)().utc();
    if (!this.#isDateDisabled(initialDate)) return initialDate;
    const { min: min2, max: max2 } = this.config;
    const minDate = min2 ? parseDate(min2) : null;
    const maxDate = max2 ? parseDate(max2) : null;
    const today = (0, import_dayjs2.default)().utc();
    if (minDate && today.isBefore(minDate)) {
      return minDate;
    }
    if (maxDate && today.isAfter(maxDate)) {
      return maxDate;
    }
    return today;
  }
  #renderTimepicker() {
    const selection = this.state.selection.pending || this.state.selection.current;
    const date = selection[0];
    this.#updateTimeInputs(date);
  }
  #renderCalendar() {
    this.#renderCalendarHeader();
    this.#renderCalendarGrid();
    this.#updateNavigationButtons();
    this.#updateRovingTabindex();
    this.#updateWeekdaysVisibility();
    this.#updateCalendarView();
  }
  #updateWeekdaysVisibility() {
    const { weekdays } = this.parts;
    if (weekdays) {
      weekdays.hidden = !this.#isDayMode();
    }
  }
  #updateCalendarView() {
    const { calendar } = this.parts;
    if (calendar) {
      const viewMode = this.#isMonthMode() ? "months" : this.#isYearMode() ? "years" : "days";
      calendar.setAttribute("data-view", viewMode);
      if (this.#isRangeMode()) {
        const selection = this.state.selection.pending || this.state.selection.current;
        const [start, end] = selection;
        const hasCompleteRange = start && end && !start.isSame(end, this.#getGranularityUnit());
        this.updateAttributes(calendar, { "data-range-complete": hasCompleteRange || false });
      }
    }
  }
  #renderCalendarHeader() {
    const { currentMonthTitle, monthSelect, yearSelect } = this.parts;
    const currentMonth = this.state.currentDate.month();
    const currentYear = this.state.currentDate.year();
    if (this.#isYearMode()) {
      const decadeStart = Math.floor(currentYear / 10) * 10;
      const decadeEnd = decadeStart + 11;
      currentMonthTitle && (currentMonthTitle.textContent = `${decadeStart} - ${decadeEnd}`);
    } else if (this.#isMonthMode()) {
      currentMonthTitle && (currentMonthTitle.textContent = String(currentYear));
    } else {
      currentMonthTitle && (currentMonthTitle.textContent = this.state.currentDate.format("MMMM YYYY"));
    }
    if (monthSelect) {
      monthSelect.hidden = !this.#isDayMode();
      monthSelect.value = String(currentMonth);
    }
    if (yearSelect) {
      yearSelect.hidden = !this.#isDayMode();
      yearSelect.value = String(currentYear);
    }
  }
  #renderCalendarGrid() {
    if (this.#isMonthMode()) {
      this.#renderMonthGrid();
    } else if (this.#isYearMode()) {
      this.#renderYearGrid();
    } else {
      this.#renderDayGrid();
    }
  }
  #renderDayGrid() {
    const { calendar } = this.parts;
    const firstDay = this.state.currentDate.startOf("month");
    const startDate = firstDay.subtract((firstDay.day() - this.config.weekStart + 7) % 7, "day");
    const totalCells = 42;
    const existingButtons = Array.from(calendar.children);
    for (let i = 0; i < totalCells; i++) {
      const date = startDate.add(i, "day");
      const isOtherMonth = !date.isSame(this.state.currentDate, "month");
      if (i < existingButtons.length) {
        this.#updateDayButton(existingButtons[i], date, isOtherMonth);
      } else {
        calendar.appendChild(this.#createDayButton(date, isOtherMonth));
      }
    }
    while (calendar.children.length > totalCells) {
      calendar.lastChild.remove();
    }
  }
  // New method to update existing buttons
  #updateDayButton(button, date, isOtherMonth) {
    const isDisabled = this.#isDateDisabled(date);
    const isHighlighted = this.state.focusedDate?.isSame(date, "day");
    const isSelected = this.#isDateSelected(date);
    const isToday = date.isSame((0, import_dayjs2.default)(), "day");
    const { isStart, isEnd, isInRange } = this.#getRangeState(date);
    const isWeekend = date.day() === 0 || date.day() === 6;
    const isWeekday = !isWeekend;
    const dateText = button.querySelector('[data-part="date-text"]');
    if (dateText) {
      dateText.textContent = date.date();
    }
    this.updateAttributes(button, {
      "data-date": date.format("YYYY-MM-DD"),
      "data-other-month": isOtherMonth || false,
      "data-today": isToday || false,
      "data-selected": isSelected || false,
      "data-highlighted": isHighlighted || false,
      "data-disabled": isDisabled || false,
      "data-range-start": isStart || false,
      "data-range-end": isEnd || false,
      "data-in-range": isInRange || false,
      "data-weekend": isWeekend || false,
      "data-weekday": isWeekday || false,
      disabled: isDisabled || false,
      "aria-disabled": String(isDisabled || false),
      tabindex: "-1"
    });
  }
  // Keep existing createDayButton method for creating new buttons
  #createDayButton(date, isOtherMonth = false) {
    const { dayTemplate } = this.parts;
    const dayButton = dayTemplate.content.cloneNode(true).firstElementChild;
    this.#updateDayButton(dayButton, date, isOtherMonth);
    return dayButton;
  }
  #renderMonthGrid() {
    const { calendar } = this.parts;
    const totalCells = 12;
    const currentYear = this.state.currentDate.year();
    const existingButtons = Array.from(calendar.children);
    for (let i = 0; i < totalCells; i++) {
      const date = (0, import_dayjs2.default)().year(currentYear).month(i).startOf("month");
      if (i < existingButtons.length) {
        this.#updateMonthButton(existingButtons[i], date);
      } else {
        calendar.appendChild(this.#createMonthButton(date));
      }
    }
    while (calendar.children.length > totalCells) {
      calendar.lastChild.remove();
    }
  }
  #updateMonthButton(button, date) {
    const isDisabled = this.#isMonthDisabled(date);
    const isHighlighted = this.state.focusedDate?.isSame(date, "month");
    const isSelected = this.#isMonthSelected(date);
    const isToday = date.isSame((0, import_dayjs2.default)(), "month");
    const { isStart, isEnd, isInRange } = this.#getRangeState(date);
    const dateText = button.querySelector('[data-part="date-text"]');
    dateText.textContent = date.format("MMM");
    this.updateAttributes(button, {
      "data-month": date.format("YYYY-MM"),
      "data-date": date.format("YYYY-MM-DD"),
      "data-today": isToday || false,
      "data-selected": isSelected || false,
      "data-highlighted": isHighlighted || false,
      "data-disabled": isDisabled || false,
      "data-range-start": isStart || false,
      "data-range-end": isEnd || false,
      "data-in-range": isInRange || false,
      "data-other-month": false,
      disabled: isDisabled || false,
      "aria-disabled": String(isDisabled || false),
      tabindex: "-1"
    });
  }
  #createMonthButton(date) {
    const { dayTemplate } = this.parts;
    const monthButton = dayTemplate.content.cloneNode(true).firstElementChild;
    this.#updateMonthButton(monthButton, date);
    return monthButton;
  }
  #renderYearGrid() {
    const { calendar } = this.parts;
    const totalCells = 12;
    const currentYear = this.state.currentDate.year();
    const decadeStart = Math.floor(currentYear / 10) * 10;
    const existingButtons = Array.from(calendar.children);
    for (let i = 0; i < totalCells; i++) {
      const date = (0, import_dayjs2.default)().year(decadeStart + i).startOf("year");
      if (i < existingButtons.length) {
        this.#updateYearButton(existingButtons[i], date);
      } else {
        calendar.appendChild(this.#createYearButton(date));
      }
    }
    while (calendar.children.length > totalCells) {
      calendar.lastChild.remove();
    }
  }
  #updateYearButton(button, date) {
    const isDisabled = this.#isYearDisabled(date);
    const isHighlighted = this.state.focusedDate?.isSame(date, "year");
    const isSelected = this.#isYearSelected(date);
    const isToday = date.isSame((0, import_dayjs2.default)(), "year");
    const { isStart, isEnd, isInRange } = this.#getRangeState(date);
    const dateText = button.querySelector('[data-part="date-text"]');
    dateText.textContent = date.format("YYYY");
    this.updateAttributes(button, {
      "data-year": date.format("YYYY"),
      "data-date": date.format("YYYY-MM-DD"),
      "data-today": isToday || false,
      "data-selected": isSelected || false,
      "data-highlighted": isHighlighted || false,
      "data-disabled": isDisabled || false,
      "data-range-start": isStart || false,
      "data-range-end": isEnd || false,
      "data-in-range": isInRange || false,
      "data-other-month": false,
      disabled: isDisabled || false,
      "aria-disabled": String(isDisabled || false),
      tabindex: "-1"
    });
  }
  #createYearButton(date) {
    const { dayTemplate } = this.parts;
    const yearButton = dayTemplate.content.cloneNode(true).firstElementChild;
    this.#updateYearButton(yearButton, date);
    return yearButton;
  }
  #getRangeState(date) {
    if (!this.config.range) {
      return {};
    }
    const selection = this.state.selection.pending || this.state.selection.current;
    const [start, end] = selection;
    const granularity = this.#getGranularityUnit();
    if (!start) return {};
    const isStart = start?.isSame(date, granularity);
    const isEnd = end?.isSame(date, granularity);
    let isInRange = false;
    if (end && !isStart && !isEnd) {
      const dateAtGranularity = (0, import_dayjs2.default)(date).startOf(granularity);
      const startAtGranularity = (0, import_dayjs2.default)(start).startOf(granularity);
      const endAtGranularity = (0, import_dayjs2.default)(end).startOf(granularity);
      isInRange = dateAtGranularity.isAfter(startAtGranularity) && dateAtGranularity.isBefore(endAtGranularity);
    }
    return {
      isStart,
      isEnd,
      isInRange
    };
  }
  #getNewRangeSelection(pickedDate, baseSelection = null) {
    const selection = baseSelection || this.state.selection.current;
    const [start, end] = selection;
    const granularity = this.#getGranularityUnit();
    if (!start) {
      return [pickedDate];
    }
    if (!end) {
      return pickedDate.isSame(start, granularity) ? [start, start] : pickedDate.isBefore(start, granularity) ? [pickedDate, start] : [start, pickedDate];
    }
    if (pickedDate.isSame(start, granularity)) {
      return [];
    }
    if (pickedDate.isSame(end, granularity)) {
      return [pickedDate];
    }
    if (pickedDate.isBefore(start, granularity)) {
      return [pickedDate, end];
    }
    if (pickedDate.isAfter(end, granularity)) {
      return [start, pickedDate];
    }
    return [start, pickedDate];
  }
  update() {
    const selection = this.#getSelectionFromInputs();
    this.#updateSelection(selection, { isPending: false });
  }
  #getSelectionFromInputs() {
    if (this.config.range) {
      return [parseDate(this.parts.inputStart?.value), parseDate(this.parts.inputEnd?.value)].filter(Boolean);
    }
    if (this.config.multiple) {
      return Array.from(this.parts.root.querySelectorAll('[data-part="input"]')).map((input) => parseDate(input.value)).filter(Boolean);
    }
    const date = parseDate(this.parts.input?.value);
    return date ? [date] : [];
  }
  #onVisibilityChange({ isOpen }) {
    if (isOpen) {
      this.state.currentDate = this.#findInitialDate();
      this.#showCalendar();
      return [
        this.bind(window, "mousedown", this.#onWindowMouseDown),
        this.bind(window, "mouseup", this.#onWindowMouseUp),
        this.bind(document, "keydown", this.#onDocumentKeyDown)
      ];
    } else {
      this.#updateSelection(this.state.selection.current);
      this.state.currentDate = null;
      this.#hideCalendar();
    }
  }
  #onDocumentKeyDown(event2) {
    if (event2.key === "Escape") {
      if (this.#isConfirmMode()) {
        this.#updateSelection(this.state.selection.current);
      }
      this.#close();
    }
  }
  #onWindowMouseDown = (event2) => {
    this.mouseDownTarget = event2.target;
  };
  #onWindowMouseUp = (event2) => {
    const { toggle, wrapper } = this.parts;
    const isOutsideToggle = !toggle.contains(this.mouseDownTarget) && !toggle.contains(event2.target);
    const isOutsideCalendar = !wrapper.contains(this.mouseDownTarget) && !wrapper.contains(event2.target);
    if (isOutsideToggle && isOutsideCalendar) {
      if (this.#isConfirmMode()) {
        this.#updateSelection(this.state.selection.current);
      }
      this.#close();
    }
    this.mouseDownTarget = null;
  };
  #onToggleClick() {
    this.state.isOpen = !this.state.isOpen;
  }
  #onDayClick(event2) {
    const date = parseDate(event2.target.dataset.date);
    this.state.pickedDate = date;
  }
  #onToggleKeyDown(event2) {
    const { code } = event2;
    if (["Enter", "Space"].includes(code)) {
      event2.preventDefault();
      this.state.isOpen = !this.state.isOpen;
    }
  }
  #onToggleBlur() {
    requestAnimationFrame(() => {
      const { activeElement } = document;
      const { wrapper, root } = this.parts;
      if (!wrapper.contains(activeElement) && !root.contains(activeElement)) {
        this.#close({ focusToggle: false });
      }
    });
  }
  #onPrevMonthClick() {
    if (this.#isYearMode()) {
      this.state.currentDate = this.state.currentDate.subtract(12, "year");
    } else if (this.#isMonthMode()) {
      this.state.currentDate = this.state.currentDate.subtract(1, "year");
    } else {
      this.state.currentDate = this.state.currentDate.subtract(1, "month");
    }
  }
  #onNextMonthClick() {
    if (this.#isYearMode()) {
      this.state.currentDate = this.state.currentDate.add(12, "year");
    } else if (this.#isMonthMode()) {
      this.state.currentDate = this.state.currentDate.add(1, "year");
    } else {
      this.state.currentDate = this.state.currentDate.add(1, "month");
    }
  }
  #onPrevYearClick() {
    this.state.currentDate = this.state.currentDate.subtract(1, "year");
  }
  #onNextYearClick() {
    this.state.currentDate = this.state.currentDate.add(1, "year");
  }
  #onYearSelectChange(event2) {
    event2.preventDefault();
    event2.stopPropagation();
    const year = event2.target.value;
    this.state.currentDate = this.state.currentDate.set("year", year);
  }
  #onMonthSelectChange(event2) {
    event2.preventDefault();
    event2.stopPropagation();
    const month = event2.target.value;
    this.state.currentDate = this.state.currentDate.set("month", month);
  }
  #onDayKeyDown(event2) {
    const { code } = event2;
    const date = parseDate(event2.target.dataset.date);
    if (!date) return;
    let newDate;
    const granularity = this.#getGranularityUnit();
    if (code === "ArrowLeft") {
      event2.preventDefault();
      newDate = this.#isYearMode() ? date.subtract(1, "year") : this.#isMonthMode() ? date.subtract(1, "month") : date.subtract(1, "day");
    } else if (code === "ArrowRight") {
      event2.preventDefault();
      newDate = this.#isYearMode() ? date.add(1, "year") : this.#isMonthMode() ? date.add(1, "month") : date.add(1, "day");
    } else if (code === "ArrowUp") {
      event2.preventDefault();
      newDate = this.#isYearMode() ? date.subtract(3, "year") : this.#isMonthMode() ? date.subtract(3, "month") : date.subtract(7, "day");
    } else if (code === "ArrowDown") {
      event2.preventDefault();
      newDate = this.#isYearMode() ? date.add(3, "year") : this.#isMonthMode() ? date.add(3, "month") : date.add(7, "day");
    } else if (code === "Enter" || code === "Space") {
      event2.preventDefault();
      this.state.pickedDate = date;
      return;
    }
    if (newDate) {
      const isDisabled = this.#isYearMode() ? this.#isYearDisabled(newDate) : this.#isMonthMode() ? this.#isMonthDisabled(newDate) : this.#isDateDisabled(newDate);
      if (isDisabled) {
        const directionMap = {
          ArrowLeft: -1,
          ArrowRight: 1,
          ArrowUp: this.#isYearMode() ? -3 : this.#isMonthMode() ? -3 : -7,
          ArrowDown: this.#isYearMode() ? 3 : this.#isMonthMode() ? 3 : 7
        };
        const direction = directionMap[code];
        if (direction) {
          const nextEnabled = this.#findNextEnabledDate(date, direction, granularity);
          if (nextEnabled) {
            newDate = nextEnabled;
          } else {
            return;
          }
        } else {
          return;
        }
      }
      if (this.#isMonthMode() && !newDate.isSame(this.state.currentDate, "year")) {
        this.state.currentDate = newDate;
      } else if (this.#isYearMode()) {
        const currentDecade = Math.floor(this.state.currentDate.year() / 10) * 10;
        const newDecade = Math.floor(newDate.year() / 10) * 10;
        if (currentDecade !== newDecade) {
          this.state.currentDate = newDate;
        }
      } else if (!newDate.isSame(this.state.currentDate, "month")) {
        this.state.currentDate = newDate;
      }
      this.state.focusedDate = newDate;
    }
  }
  async #showCalendar() {
    const { wrapper } = this.parts;
    wrapper.hidden = false;
    this.position = new Position4(this.parts);
    this.position.setup();
    this.focusTrap = new FocusTrap(this.parts.wrapper, { content: this.parts.wrapper });
    this.focusTrap.activate();
    await this.animator.animateEnter(wrapper);
  }
  async #hideCalendar() {
    const { wrapper } = this.parts;
    if (await this.animator.animateLeave(wrapper)) {
      wrapper.hidden = true;
      this.focusTrap.deactivate();
      this.position.destroy();
      this.position = null;
      this.focusTrap = null;
    }
  }
  #updateNavigationButtons() {
    const { prevMonthButton, nextMonthButton, nextYearButton, prevYearButton } = this.parts;
    let prevPeriodCheck, nextPeriodCheck;
    if (this.#isMonthMode()) {
      prevPeriodCheck = this.state.currentDate.subtract(1, "year").endOf("year");
      nextPeriodCheck = this.state.currentDate.add(1, "year").startOf("year");
    } else if (this.#isYearMode()) {
      prevPeriodCheck = this.state.currentDate.subtract(12, "year").endOf("year");
      nextPeriodCheck = this.state.currentDate.add(12, "year").startOf("year");
    } else {
      prevPeriodCheck = this.state.currentDate.subtract(1, "month").endOf("month");
      nextPeriodCheck = this.state.currentDate.add(1, "month").startOf("month");
    }
    prevMonthButton.disabled = this.#isDateOutsideBounds(prevPeriodCheck);
    nextMonthButton.disabled = this.#isDateOutsideBounds(nextPeriodCheck);
    if (prevYearButton) {
      const lastDayPrevYear = this.state.currentDate.subtract(1, "year").endOf("month");
      prevYearButton.disabled = this.#isDateOutsideBounds(lastDayPrevYear);
    }
    if (nextYearButton) {
      const firstDayNextYear = this.state.currentDate.add(1, "year").startOf("month");
      nextYearButton.disabled = this.#isDateOutsideBounds(firstDayNextYear);
    }
  }
  // This function manages keyboard focus in the calendar. It's a bit tricky because
  // we need to handle both single date and range selection modes, while keeping
  // keyboard navigation accessible. Here's how it works:
  //
  // 1. First, it finds all clickable days (not disabled)
  // 2. Then it looks for a day to focus in this order:
  //    - The day you're currently navigating with keyboard (focusedDate)
  //    - The selected date(s) - either single date or range start/end
  //    - Today's date as a sensible default
  //    - Any date in current month (not from prev/next month)
  //    - If nothing else works, just the first available day
  //
  // The findDay helper is smart - it can handle both dates (comparing with isSame)
  // and predicates (like checking for data-today attribute). This makes the
  // candidates array cleaner since we can mix both types.
  //
  // Focus behavior:
  // - We only force focus on days during keyboard navigation (focusedDate changes)
  // - During month navigation (prev/next buttons), we respect the current focus
  // - In range mode, we keep focus on days to maintain selection context
  #updateRovingTabindex() {
    const validDays = Array.from(this.parts.calendar.querySelectorAll("button[data-date]:not([disabled])"));
    if (validDays.length === 0) return;
    const findDay = (date) => date && validDays.find((day) => parseDate(day.dataset.date)?.isSame(date, "day"));
    const focusableDay = findDay(this.state.focusedDate) || findDay(this.state.selection.current[0]) || validDays.find((day) => day.hasAttribute("data-today")) || validDays[0];
    validDays.forEach((day) => {
      this.updateAttributes(day, {
        tabindex: day === focusableDay ? "0" : "-1",
        autofocus: day === focusableDay
      });
    });
  }
  #onAmPmSelectChange(event2) {
    if (event2.type === "keydown") {
      const { key } = event2;
      if (key === "Enter") {
        event2.preventDefault();
        if (this.#isConfirmMode()) {
          if (!this.parts.applyButton.disabled) {
            this.#onApplyButtonClick();
          }
        } else {
          this.#close();
        }
        return;
      }
      if (key === "ArrowUp" || key === "ArrowDown") {
        event2.preventDefault();
        const currentValue = event2.target.value;
        const newValue = currentValue === "am" ? "pm" : "am";
        event2.target.value = newValue;
        this.#handleAmPmToggle(newValue === "pm");
        return;
      }
      if (key === "Tab") {
        return;
      }
      event2.preventDefault();
      if (key.toLowerCase() === "a") {
        event2.target.value = "am";
        this.#handleAmPmToggle(false);
      } else if (key.toLowerCase() === "p") {
        event2.target.value = "pm";
        this.#handleAmPmToggle(true);
      }
    } else {
      const isPm = event2.target.value === "pm";
      this.#handleAmPmToggle(isPm);
    }
  }
  #handleAmPmToggle(isPm) {
    let selection = this.#getWorkingSelection();
    if (!selection?.length) return;
    const [currentDate, ...restDates] = selection;
    const hour = currentDate.hour();
    const currentPm = hour >= 12;
    if (currentPm !== isPm) {
      const newHour = isPm ? hour + 12 : hour - 12;
      const updatedDate = this.#updateDateTimeValue(currentDate, "hour", newHour);
      this.#updateSelection([updatedDate, ...restDates], { isPending: this.#shouldUsePendingSelection() });
    }
  }
  #handleTimeInput(type, action, value) {
    const handlers = {
      backspace: (current) => Math.floor(current / 10),
      increment: (current, max3, _min = 0) => Math.min(current + 1, max3),
      decrement: (current, _max, min3 = 0) => Math.max(current - 1, min3),
      digit: (current, digit, max3, min3 = 0) => {
        const newValue2 = current % 10 * 10 + digit;
        return Math.min(Math.max(newValue2 > max3 ? digit : newValue2, min3), max3);
      }
    };
    const limits = {
      hour: {
        24: { min: 0, max: 23 },
        12: { min: 1, max: 12 }
      },
      minute: { min: 0, max: 59 },
      second: { min: 0, max: 59 }
    };
    let selection = this.#getWorkingSelection();
    if (!selection?.length) return;
    const [currentDate, ...restDates] = selection;
    let currentValue = currentDate[type]();
    const { min: min2, max: max2 } = type === "hour" ? limits.hour[this.config.timeFormat] : limits[type] || {};
    if (type === "hour" && this.config.timeFormat === "12") {
      currentValue = currentValue % 12 || 12;
    }
    const handler = handlers[action];
    const newValue = action === "digit" ? handler(currentValue, value, max2, min2) : handler(currentValue, max2, min2);
    let finalValue = newValue;
    if (type === "hour" && this.config.timeFormat === "12") {
      const isPm = this.parts.amPmSelect?.value === "pm";
      finalValue = newValue === 12 ? isPm ? 12 : 0 : isPm ? newValue + 12 : newValue;
    }
    const updatedDate = this.#updateDateTimeValue(currentDate, type, finalValue);
    this.#updateSelection([updatedDate, ...restDates], { isPending: this.#shouldUsePendingSelection() });
  }
  #isTimeInputKey(key) {
    return /^[0-9]$/.test(key) || key === "ArrowUp" || key === "ArrowDown" || key === "Backspace" || key === "Delete";
  }
  #onTimeKeyDown(event2, type) {
    const { key, ctrlKey, metaKey, altKey } = event2;
    if (ctrlKey || metaKey || altKey) {
      return;
    }
    if (key === "Tab" || key === "Escape") {
      return;
    }
    if (key === "Enter") {
      event2.preventDefault();
      if (this.#isConfirmMode()) {
        if (!this.parts.applyButton.disabled) {
          this.#onApplyButtonClick();
        }
      } else {
        this.#close();
      }
      return;
    }
    if (this.#isTimeInputKey(key)) {
      event2.preventDefault();
      if (key === "ArrowUp") {
        this.#handleTimeInput(type, "increment");
      } else if (key === "ArrowDown") {
        this.#handleTimeInput(type, "decrement");
      } else if (key === "Backspace" || key === "Delete") {
        this.#handleTimeInput(type, "backspace");
      } else if (/^[0-9]$/.test(key)) {
        this.#handleTimeInput(type, "digit", parseInt(key, 10));
      }
    }
  }
  #onCancelButtonClick() {
    this.#updateSelection(this.state.selection.current);
    this.#close();
  }
  #onApplyButtonClick() {
    const pendingSelection = this.state.selection.pending || [];
    this.#updateSelection(pendingSelection);
    this.#close();
  }
  #close({ focusToggle = true } = {}) {
    if (this.config.inline) return;
    this.state.isOpen = false;
    if (focusToggle) this.parts.toggle?.focus();
  }
  #updateTimeInputs(date) {
    const { hourInput, minuteInput, secondInput, amPmSelect } = this.parts;
    if (!date) {
      this.updateAttributes(hourInput, { disabled: true, value: "00" });
      this.updateAttributes(minuteInput, { disabled: true, value: "00" });
      this.updateAttributes(secondInput, { disabled: true, value: "00" });
      if (amPmSelect) {
        this.updateAttributes(amPmSelect, { disabled: true, value: "am" });
      }
      return;
    }
    let displayHour = date.hour();
    if (this.config.timeFormat === "12") {
      displayHour = displayHour % 12 || 12;
    }
    this.updateAttributes(hourInput, {
      disabled: false,
      value: String(displayHour).padStart(2, "0"),
      min: this.config.timeFormat === "12" ? "1" : "0",
      max: this.config.timeFormat === "12" ? "12" : "23"
    });
    this.updateAttributes(minuteInput, { disabled: false, value: String(date.minute()).padStart(2, "0") });
    this.updateAttributes(secondInput, { disabled: false, value: String(date.second()).padStart(2, "0") });
    if (amPmSelect) {
      const amPmValue = date.hour() >= 12 ? "pm" : "am";
      amPmSelect.value = amPmValue;
      this.updateAttributes(amPmSelect, { disabled: false, value: amPmValue });
    }
  }
};

// js/hooks/date_picker.js
var date_picker_default = {
  mounted() {
    this.datePicker = new DatePicker(this.el);
  },
  updated() {
    this.datePicker.update();
  },
  destroyed() {
    this.datePicker.destroy();
  }
};

// js/components/autocomplete/autocomplete.js
var Autocomplete = class extends component_default {
  #positionCleanup = null;
  #searchTimeout = null;
  #mouseDownTarget = null;
  static name = "Autocomplete";
  constructor(element) {
    super(element);
    this.animator = new Animator();
  }
  setup() {
    return {
      // Define the DOM structure
      parts: {
        input: { selector: '[data-part="input"]', required: true },
        fieldRoot: { selector: '[data-part="field-root"]', required: true },
        hiddenInput: { selector: '[data-part="hidden-input"]', required: true },
        listbox: { selector: '[data-part="listbox"]', required: true },
        optionsList: { selector: '[data-part="options-list"]', required: true },
        emptyMessage: { selector: '[data-part="empty-message"]', required: true },
        loading: { selector: '[data-part="loading"]', required: true },
        emptyState: { selector: '[data-part="empty-state"]', required: false },
        clearButton: { selector: '[data-part="clear-button"]', required: false },
        options: {
          selector: '[data-part="option"]',
          required: false,
          multiple: true,
          onChange: (value) => {
            this.state.options = Array.from(value);
          }
        }
      },
      // Define component configuration
      config: {
        searchThreshold: { type: "number", default: 0 },
        searchMode: { type: "enum", default: "contains", values: ["contains", "starts-with", "exact"] },
        openOnFocus: { type: "boolean", default: false },
        noResultsText: { type: "string", default: "No results found for %{query}." },
        onSearch: { type: "string", default: null },
        debounceMs: { type: "number", default: 200 }
      },
      // Define component state
      state: {
        // Controls the visibility of the listbox
        open: {
          default: false
        },
        // Prevents reopening on focus after selection
        preventReopenOnFocus: {
          default: false
        },
        // Current highlighted option index (-1 means no highlight)
        highlightedIndex: {
          default: -1
        },
        // Indicates if a search operation is in progress
        loading: {
          default: false
        },
        // Query State
        // Represents the current search text entered by the user.
        //
        // This state triggers search operations and is used to:
        // - Filter options in client-side search
        // - Send search requests in server-side search
        // - Clear selection when empty
        //
        // Initialized from the input's value to maintain consistency
        // with the DOM state.
        query: {
          default: "",
          init: () => this.parts.input?.value || ""
        },
        // Selection State
        // Tracks the currently selected option.
        //
        // Structure:
        // {
        //   value: string  // The option's value (used for form submission)
        //   label: string  // The display text
        // }
        //
        // This state is observed to:
        // - Update input values
        // - Update option attributes
        // - Trigger change events
        //
        // Initialized from any pre-selected option in the DOM.
        selection: {
          default: null,
          init() {
            const selectedOption = Array.from(this.parts.options).find((option) => option.hasAttribute("data-selected"));
            if (selectedOption) {
              return {
                value: selectedOption.dataset.value,
                label: selectedOption.textContent.trim()
              };
            }
            return null;
          }
        },
        // Options State
        // Maintains the list of available options.
        //
        // This state is:
        // - Initialized from DOM options
        // - Updated when options are dynamically added/removed
        // - Used to calculate visible options for rendering
        //
        // Each option maintains its own hidden state for filtering.
        options: {
          default: [],
          init() {
            return Array.from(this.parts.options || []);
          }
        },
        // Active Change Events Counter
        // Tracks ongoing server-side search requests to prevent race conditions.
        //
        // Used to:
        // - Ensure loading state is only cleared when all requests are complete
        // - Handle overlapping search requests when typing quickly
        //
        // The loading state should only be cleared when this counter reaches 0.
        activeChangeEvents: { default: 0 }
      },
      effects: {
        // Handle listbox visibility
        handleVisibility: {
          observe: ["open"],
          run: async ({ open }) => {
            const { listbox } = this.parts;
            if (open) {
              listbox.hidden = false;
              await this.#updatePosition();
              await this.animator.animateEnter(listbox);
              return [this.bind(window, "mousedown", this.#onWindowMouseDown), this.bind(window, "mouseup", this.#onWindowMouseUp)];
            } else {
              if (await this.animator.animateLeave(listbox)) {
                listbox.hidden = true;
              }
            }
          }
        },
        // Handle highlight updates
        handleHighlight: {
          observe: ["highlightedIndex"],
          run: ({ highlightedIndex }) => {
            const { options } = this.parts;
            options.forEach((option) => {
              this.updateAttributes(option, {
                "data-highlighted": false
              });
            });
            const highlightedOption = this.visibleOptions[highlightedIndex];
            if (highlightedOption) {
              this.updateAttributes(highlightedOption, {
                "data-highlighted": true
              });
              highlightedOption.scrollIntoView({ block: "nearest" });
            }
          }
        },
        // Handle loading state
        handleLoadingState: {
          observe: ["loading", "options"],
          run: ({ loading }) => {
            const { loading: loadingElement, optionsList, emptyMessage, emptyState } = this.parts;
            const hasOptions = this.visibleOptions.length > 0;
            loadingElement.hidden = !loading;
            optionsList.hidden = loading || !hasOptions;
            emptyMessage.hidden = loading || hasOptions;
            if (emptyState) {
              emptyState.hidden = loading || hasOptions;
              emptyMessage.hidden = true;
            }
          }
        },
        // Handle ARIA attributes
        handleAria: {
          observe: ["open", "highlightedIndex"],
          run: ({ open, highlightedIndex }) => {
            const { input, listbox } = this.parts;
            const highlightedOption = this.visibleOptions[highlightedIndex];
            this.updateAttributes(input, {
              "aria-expanded": String(open),
              "aria-activedescendant": highlightedOption?.id || "",
              "aria-controls": listbox.id
            });
          }
        },
        // Handle search
        handleSearch: {
          observe: ["query"],
          run: async ({ query }) => {
            this.parts.emptyMessage.innerHTML = this.config.noResultsText.replace("%{query}", `<strong>${query}</strong>`);
            if (query.length === 0) {
              this.state.selection = null;
            }
            if (query.length >= this.config.searchThreshold) {
              this.state.loading = true;
              this.state.highlightedIndex = -1;
              this.state.open = true;
              if (this.config.onSearch) {
                await this.#handleServerSearch(query);
              } else {
                this.#handleClientSearch(query);
              }
            } else {
              this.state.open = false;
            }
          }
        },
        // Handle selection
        handleSelection: {
          observe: ["selection"],
          run: ({ selection }) => {
            const { input, hiddenInput, options } = this.parts;
            input.value = selection?.label || "";
            hiddenInput.value = selection?.value || "";
            hiddenInput.dispatchEvent(new Event("change", { bubbles: true }));
            options.forEach((option) => {
              const isSelected = option.dataset.value === selection?.value;
              this.updateAttributes(option, {
                "aria-selected": String(isSelected),
                "data-selected": isSelected
              });
            });
            this.updateAttributes(this.parts.clearButton, { "data-enabled": selection !== null });
          }
        },
        // Clear highlight when closing
        handleClose: {
          observe: ["open"],
          when: ({ open }) => !open,
          run: () => {
            this.state.highlightedIndex = -1;
          }
        }
      },
      // Define event bindings
      bindings: {
        input: {
          input: (e) => this.#onInput(e),
          keydown: (e) => this.#onKeyDown(e),
          click: (e) => this.#onInputClick(e),
          change: (e) => {
            e.preventDefault();
            e.stopPropagation();
          },
          focus: (e) => {
            if (!this.state.preventReopenOnFocus && this.config.openOnFocus && this.state.query.length >= this.config.searchThreshold) {
              this.state.open = true;
            }
            this.state.preventReopenOnFocus = false;
          }
        },
        root: {
          focusout: (e) => this.#onFocusOut(e)
        },
        listbox: {
          mousedown: (e) => {
            if (e.target === this.parts.listbox || e.target === this.parts.optionsList) {
              e.preventDefault();
            }
          },
          click: {
            handler: (e) => this.#onOptionClick(e),
            delegate: '[data-part="option"]'
          },
          mouseover: {
            handler: (e) => this.#onOptionHover(e),
            delegate: '[data-part="option"]'
          }
        },
        clearButton: {
          mousedown: (e) => e.preventDefault(),
          click: (e) => this.#onClearButtonClick(e)
        }
      }
    };
  }
  // Moves the highlight in the specified direction
  // Handles edge cases and wrapping
  #moveHighlight(direction) {
    const options = this.visibleOptions;
    if (!options.length) return;
    let newIndex = this.state.highlightedIndex;
    if (newIndex === -1) {
      newIndex = direction === "next" ? 0 : options.length - 1;
    } else {
      newIndex = direction === "next" ? Math.min(newIndex + 1, options.length - 1) : Math.max(newIndex - 1, 0);
    }
    this.state.highlightedIndex = newIndex;
  }
  // Selects an option and updates component state
  #selectOption(option) {
    if (!option) return;
    this.state.selection = {
      value: option.dataset.value,
      label: option.dataset.label
    };
    this.state.preventReopenOnFocus = true;
    this.state.open = false;
    this.parts.input.focus();
  }
  // Selects the currently highlighted option
  #selectHighlightedOption() {
    const { highlightedIndex } = this.state;
    const options = this.visibleOptions;
    if (highlightedIndex >= 0 && highlightedIndex < options.length) {
      this.#selectOption(options[highlightedIndex]);
    }
  }
  // Handles client-side filtering of options
  #handleClientSearch(query) {
    const searchQuery = query.toLowerCase();
    let hasVisibleOptions = false;
    this.parts.options.forEach((option) => {
      const text = option.textContent.trim().toLowerCase();
      let isMatch = false;
      if (searchQuery === "") {
        isMatch = true;
      } else {
        switch (this.config.searchMode) {
          case "starts-with":
            isMatch = text.startsWith(searchQuery);
            break;
          case "exact":
            isMatch = text === searchQuery;
            break;
          case "contains":
            isMatch = text.includes(searchQuery);
        }
      }
      option.hidden = !isMatch;
      hasVisibleOptions = hasVisibleOptions || isMatch;
    });
    this.state.loading = false;
    this.state.highlightedIndex = hasVisibleOptions ? 0 : -1;
  }
  // Handles server-side search requests
  #handleServerSearch(query) {
    if (this.#searchTimeout) clearTimeout(this.#searchTimeout);
    return new Promise((resolve) => {
      this.#searchTimeout = setTimeout(() => {
        this.state.activeChangeEvents++;
        this.parts.root.dispatchEvent(
          new CustomEvent("fluxon:autocomplete:search", {
            bubbles: true,
            detail: {
              query,
              id: this.parts.input.id,
              callback: this.config.onSearch,
              onComplete: () => {
                this.state.activeChangeEvents--;
                if (this.state.activeChangeEvents === 0) {
                  this.state.loading = false;
                }
                resolve();
              }
            }
          })
        );
      }, this.config.debounceMs);
    });
  }
  get visibleOptions() {
    return this.state.options.filter((option) => !option.hidden);
  }
  #onInputClick(event2) {
    if (this.state.query.length >= this.config.searchThreshold) {
      this.state.open = true;
    }
  }
  #onInput(event2) {
    event2.stopPropagation();
    const value = event2.target.value.trim();
    if (value.length === 0) {
      this.state.selection = null;
    }
    this.state.query = value;
  }
  #onKeyDown(event2) {
    const keyHandlers = {
      ArrowDown: () => this.#handleArrowKey("next", event2),
      ArrowUp: () => this.#handleArrowKey("previous", event2),
      Enter: () => this.#handleEnterKey(event2),
      Escape: () => this.#handleEscapeKey(event2)
    };
    const handler = keyHandlers[event2.key];
    if (handler) handler();
  }
  #handleArrowKey(direction, event2) {
    event2.preventDefault();
    if (this.state.query.length >= this.config.searchThreshold) {
      if (this.state.open) {
        this.#moveHighlight(direction);
      } else {
        const selectedIndex = this.visibleOptions.findIndex((option) => option.hasAttribute("data-selected"));
        this.state.open = true;
        this.state.highlightedIndex = selectedIndex !== -1 ? selectedIndex : direction === "next" ? 0 : this.visibleOptions.length - 1;
      }
    }
  }
  #handleEnterKey(event2) {
    if (!this.state.open) return;
    event2.preventDefault();
    this.#selectHighlightedOption();
  }
  #handleEscapeKey(event2) {
    if (!this.state.open) return;
    event2.preventDefault();
    event2.stopPropagation();
    this.state.open = false;
    this.parts.input.focus();
  }
  #onFocusOut(event2) {
    const focusNode = event2.relatedTarget;
    const { input, listbox } = this.parts;
    if (!focusNode || !(focusNode === input || listbox.contains(focusNode))) {
      this.state.open = false;
      return;
    }
  }
  #onOptionClick(event2) {
    const option = event2.target.closest('[data-part="option"]');
    this.#selectOption(option);
  }
  #onClearButtonClick(event2) {
    event2.preventDefault();
    event2.stopPropagation();
    this.state.selection = null;
    this.state.query = "";
    this.parts.input.value = "";
    this.parts.input.focus();
  }
  #onOptionHover(event2) {
    const option = event2.target.closest('[data-part="option"]');
    if (option && !option.hidden) {
      const index = this.visibleOptions.indexOf(option);
      if (index !== -1) {
        this.state.highlightedIndex = index;
      }
    }
  }
  async #updatePosition() {
    const { fieldRoot: reference, listbox: floating } = this.parts;
    const updatePosition = () => {
      computePosition2(reference, floating, {
        placement: "bottom-start",
        strategy: "fixed",
        middleware: [
          offset2(5),
          shift2({ padding: 5 }),
          size2({
            padding: 20,
            apply: ({ availableHeight, rects }) => {
              const referenceRect = rects.reference;
              let finalHeight;
              if (floating.dataset.cachedMaxHeight) {
                const cachedHeight = parseInt(floating.dataset.cachedMaxHeight, 10);
                finalHeight = Math.min(cachedHeight, Math.max(150, availableHeight));
              } else if (!floating.dataset.heightChecked) {
                const cssMaxHeight = floating.style.maxHeight || window.getComputedStyle(floating).getPropertyValue("max-height");
                const hasExplicitHeight = cssMaxHeight && !["none", "auto"].includes(cssMaxHeight);
                if (hasExplicitHeight) {
                  const cssHeight = parseInt(cssMaxHeight, 10);
                  floating.dataset.cachedMaxHeight = cssHeight;
                  finalHeight = Math.min(cssHeight, Math.max(150, availableHeight));
                } else {
                  finalHeight = Math.max(150, availableHeight);
                }
                floating.dataset.heightChecked = "true";
              } else {
                finalHeight = Math.max(150, availableHeight);
              }
              Object.assign(floating.style, {
                maxHeight: `${finalHeight}px`,
                minWidth: `${referenceRect.width}px`
              });
              void floating.offsetWidth;
            }
          }),
          flip2()
        ]
      }).then(({ x, y }) => {
        Object.assign(floating.style, {
          left: `${x}px`,
          top: `${y}px`,
          width: "max-content"
        });
      });
    };
    updatePosition();
    this.#positionCleanup = autoUpdate(reference, floating, updatePosition);
    window.addEventListener("resize", updatePosition);
    const originalCleanup = this.#positionCleanup;
    this.#positionCleanup = () => {
      originalCleanup();
      window.removeEventListener("resize", updatePosition);
      delete floating.dataset.cachedMaxHeight;
      delete floating.dataset.heightChecked;
    };
  }
  // Store the element where mousedown occurred
  #onWindowMouseDown = (event2) => {
    this.#mouseDownTarget = event2.target;
  };
  // Handle click outside component
  #onWindowMouseUp = (event2) => {
    const { input, listbox } = this.parts;
    const isOutsideClick = !// Check mousedown target
    (this.#mouseDownTarget === input || listbox.contains(this.#mouseDownTarget) || // Check mouseup target
    event2.target === input || listbox.contains(event2.target));
    if (isOutsideClick) {
      this.state.open = false;
    }
    this.#mouseDownTarget = null;
  };
  destroy() {
    if (this.#positionCleanup) {
      this.#positionCleanup();
      this.#positionCleanup = null;
    }
  }
};

// js/hooks/autocomplete.js
var autocomplete_default = {
  mounted() {
    this.autocomplete = new Autocomplete(this.el);
    this.el.addEventListener("fluxon:autocomplete:search", (event2) => {
      this.pushEventTo(this.el, event2.detail.callback, { query: event2.detail.query, id: event2.detail.id }, () => {
        event2.detail.onComplete();
      });
    });
  },
  updated() {
  },
  destroyed() {
    this.autocomplete.destroy();
  }
};

// js/hooks/index.js
var hooks_default = {
  "Fluxon.Tooltip": tooltip_default,
  "Fluxon.Popover": popover_default,
  "Fluxon.Tabs": tabs_default,
  "Fluxon.Dropdown": dropdown_default,
  "Fluxon.Dialog": dialog_default,
  "Fluxon.Select": select_default,
  "Fluxon.Accordion": accordion_default,
  "Fluxon.DatePicker": date_picker_default,
  "Fluxon.Autocomplete": autocomplete_default
};

// js/index.js
var DOM = {
  // A list of parts that we want to preserve styles for.
  preservedStyleParts: /* @__PURE__ */ new Set([
    "listbox",
    "popover",
    "dialog",
    "dialog-wrapper",
    "backdrop",
    "menu",
    "wrapper",
    "option",
    "loading",
    "empty-message",
    "empty-state",
    "options-list"
  ]),
  // Copies styles from one element to another to preserve them during LiveView DOM patches.
  // This is particularly important for elements that have dynamic styles (like animations
  // or transitions) that we don't want LiveView to override during its DOM diffing process.
  //
  // We copy both cssText and className because:
  // - cssText captures inline styles (style="...") which often contain computed/dynamic values
  // - className preserves CSS classes that might be dynamically added/removed (e.g. animations)
  copyStyles(from, to) {
    to.style.cssText = from.style.cssText;
    to.className = from.className;
  },
  // Copies attributes from `from` element to `to` element to preserve them during LiveView DOM patches.
  // This is particularly important for elements that have dynamic attributes (e.g. data-highlighted
  // on select options) that we want to persist through LiveView's DOM diffing process for a better
  // user experience.
  //
  // Elements can specify which attributes to preserve by adding a `keep-` prefix, e.g.:
  // <div keep-data-highlighted data-highlighted> will preserve the data-highlighted attribute
  // <div keep-aria-selected aria-selected> will preserve the aria-selected attribute
  copyDataAttributes(from, to) {
    const keepAttributes = Array.from(from.attributes).filter((attr) => attr.name.startsWith("keep-")).map((attr) => attr.name.replace("keep-", ""));
    keepAttributes.forEach((attrName) => {
      if (from.hasAttribute(attrName)) {
        to.setAttribute(attrName, from.getAttribute(attrName));
      }
    });
  },
  onBeforeElUpdated(from, to) {
    const fromPart = from.getAttribute("data-part");
    if (fromPart && this.preservedStyleParts.has(fromPart)) {
      to.hidden = from.hidden;
      this.copyStyles(from, to);
    }
    this.copyDataAttributes(from, to);
  }
};
