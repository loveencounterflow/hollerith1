![](https://github.com/loveencounterflow/hollerith/raw/master/art/hollerith.png)


- [<tt>$.|HOLLERITH|</tt>](#<tt>$|hollerith|<tt>)
- [xxx](#xxx)

> **Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*


## <tt>$.|HOLLERITH|</tt>


use LevelDB like 1969


## xxx

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


