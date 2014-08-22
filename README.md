![](https://github.com/loveencounterflow/hollerith/raw/master/art/hollerith.png)


- [hollerith](#hollerith)
- [What is LevelDB?](#what-is-leveldb)
	- [Lexicographic Order and UTF-8](#lexicographic-order-and-utf-8)
- [xxx](#xxx)

> **Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*


## hollerith


use LevelDB like 1969


## What is LevelDB?

LevelDB is fast key/value store developed and opensourced by Google and made readily available to NodeJS
folks as `npm install level` (see [level](https://github.com/level/level) and
[levelup](https://github.com/rvagg/node-levelup)).

LevelDB is very focussed on doing this one thing—being a key/value store—and forgoes a lot of features
you might expect a modern database should provide; in particular, LevelDB

* is a pure in-process DB; there are no other communication mechanisms like an HTTP API or somesuch;
* does not provide indexes on data;
* does not have data types or even have a concept of string encoding—all keys and values are just
  arbitrary byte sequences;
* does not have intricate transaction handling (although it does feature compound batch operations that
  either succeed or fail with no partial commits);

What LevelDB does have, on the other hand is this (names given are for `hollerith` plus, in brackets,
their equivalents in `levelup`):

* **a `set key, value` (`levelup`: `put`) operation that stores a key / value pair (let's call that a 'facet' for short),**
* **a `get key` (`levelup`: `get`) operation that either yields the value that was `put` under that key, or else throws an
  error in case the key is not found,**
* **a `drop key` (`levelup`: `del`) operation that erases a key and its value from the records,**

and, most interestingly:

* **a `read ...` (`levelup`: `createReadStream`) operation that walks over keys, lexicographically
  ordered by their byte sequences; this can optionally be confined by setting a lower and an upper bound**.

### Lexicographic Order and UTF-8

The term '[lexicographically ordered](http://en.wikipedia.org/wiki/Lexicographical_order)' deserves some
explanation: lexicographical ordering (in computer science) is somewhat different from alphabetical ordering
(used in phone directories, card files and dictionaries) in that only the underlying bits of the binary
representation are considered to decide what comes first and what comes next.

When using Unicode, the naïve, old-fashioned way of constructing an upper limit by appending Latin-1 `ÿ`
(`0xff`) to the key does *not* work.

UCS-2

"The lexicographic sorting order of UCS-4 strings is preserved."—[RFC 2044](https://www.ietf.org/rfc/rfc2044.txt)



|  chr   |          hex          |                  bin                  |
| ------ | --------------------- | ------------------------------------- |
| `'a'`  | `0x61`                | `01100001`                            |
| `'b'`  | `0x62`                | <tt>011000<b>1</b>0</tt>                            |
| `'c'`  | `0x63`                | <tt>0110001<b>1</b></tt>                            |
| `'1'`  | `0xc3 0xa4`           | <tt>11000011 <b>1</b>0100100</tt>                   |
| `'ÿ'`  | `0xc3 0xbf`           | <tt>11000011 <b>1</b>0111111</tt>                   |
| `'Θ'`  | `0xce 0x98`           | <tt>1100<b>1</b>110 10011000</tt>                   |
| `'中'` | `0xe4 0xb8 0xad`      | <tt>11<b>1</b>00100 10111000 10101101</tt>          |
| `'𠀀'`  | `0xf0 0xa0 0x80 0x80` | <tt>111<b>1 ⃝</b>0000 10100000 10000000 10000000</tt> |
| `'�'`  | `0xff`                | <tt>1111<b>x</b>111</tt>                            |




## xxx

![](https://github.com/loveencounterflow/hollerith/raw/master/art/082.jpg)



samples:

```coffee
gtfs:
  stoptime:
    id:               gtfs/stoptime/876
    stop-id:          gtfs/stop/123
    trip-id:          gtfs/trip/456
    ...
    arr:              15:38
    dep:              15:38


  stop:
    id:               gtfs/stop/123
    name:             Bayerischer+Platz
    ...

  trip:
    id:               gtfs/trip/456
    route-id:         gtfs/route/777
    service-id:       gtfs/service/888

  route:
    id:               gtfs/route/777
    name:             U4

$ . | realm / type / idn
$ : | realm / type / idn | name | value
$ ^ | realm₀ / type₀ / idn₀|>realm₁ / type₁ / idn₁


$:|gtfs/route/777|0|name|U4
$:|gtfs/stop/123|0|name|Bayerischer+Platz
$:|gtfs/stoptime/876|0|arr|15%2538
$:|gtfs/stoptime/876|0|dep|15%2538
$^|gtfs/stoptime/876|0|gtfs/stop/123
$^|gtfs/stoptime/876|0|gtfs/trip/456
$^|gtfs/trip/456|0|gtfs/route/777
$^|gtfs/trip/456|0|gtfs/service/888


  $^|gtfs/stoptime/876|gtfs/trip/456
+                   $^|gtfs/trip/456|gtfs/route/777
—————————————————————————————————————————————————————————
= %^|gtfs/stoptime| 2               |gtfs/route/777|876
+                                 $:|gtfs/route/777|name|U4
—————————————————————————————————————————————————————————
= %:|gtfs/stoptime/876              |gtfs/route/    name|U4

# or

= gtfs/stoptime/876|=gtfs/route|name:U4

# or

= gtfs/stoptime/876|=2>gtfs/route|name:U4|777



  gtfs/stoptime/876|-1>gtfs/trip/456
                        gtfs/trip/456|-1>gtfs/service/888
——————————————————————————————————————————————————————————————————
= gtfs/stoptime/876|-2>gtfs/service/888
——————————————————————————————————————————————————————————————————


% : | realm / type   | name | value | idn
% ^ | realm₀ / type₀ | n | realm₁ / type₁ / idn₁ | idn₀

%:|gtfs/route|0|name|U4|777
%:|gtfs/stoptime|0|arr|15%2538|876
%:|gtfs/stoptime|0|dep|15%2538|876
%:|gtfs/stop|0|name|Bayerischer+Platz|123
%^|gtfs/stoptime|0|gtfs/stop/123|876
%^|gtfs/stoptime|0|gtfs/trip/456|876
%^|gtfs/stoptime|1|gtfs/route/777|876
%^|gtfs/stoptime|1|gtfs/service/888|876
%^|gtfs/trip|0|gtfs/route/777|456
%^|gtfs/trip|0|gtfs/service/888|456


realm
type
name
value
idn

joiner      |
%
escape_chr
=
>
:
^
```


