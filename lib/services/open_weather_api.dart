import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenWeatherApi {
  Future<dynamic> getWeatherData(double lat, double lon) async {
    try {
      final apiKey = dotenv.env['apiKey'];
      if (apiKey == null) {
        print('Error: API key is not set in .env');
      } else {
        final response = await http.get(Uri.parse(
            'https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lon}&appid=${apiKey}'));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print(data);
          return data;
        } else {
          print('Error: ${response.reasonPhrase}');
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<dynamic> getSuggestions(String query) async {
    try {
      final apiKey = dotenv.env['apiKey'];
      if (apiKey == null) {
        print('Error: API key is not set in .env');
      } else {
        final response = await http.get(Uri.parse(
            'http://api.openweathermap.org/geo/1.0/direct?q=$query&limit=5&appid=$apiKey'));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return(data);
        } else {
          print('Error: ${response.reasonPhrase}');
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}

// name: ,local_names: {}, lat: ,lon: ,country: ,state:

// Sample output {coord: {lon: 77.2167, lat: 28.6448}, weather: [{id: 721, main: Haze, description: haze, icon: 50d}], base: stations,
// main: {temp: 305.19, feels_like: 306.05, temp_min: 305.19, temp_max: 305.19, pressure: 1009, humidity: 43, sea_level: 1009, grnd_level: 984},
// visibility: 3500, wind: {speed: 1.03, deg: 0}, clouds: {all: 0}, dt: 1729512095, sys: {type: 1, id: 9165, country: IN, sunrise: 1729472134, sunset: 1729512935},
// timezone: 19800, id: 1273840, name: Connaught Place, cod: 200}


// Sample output [{name: Paris, local_names: {gv: Paarys, km: ប៉ារីស, de: Paris, ku: Parîs, bg: Париж, sc: Parigi, sr: Париз, ta: பாரிஸ், co: Parighji, af: Parys,
// mk: Париз, th: ปารีส, fy: Parys, bs: Pariz, pl: Paryż, kv: Париж, cs: Paříž, ht: Pari, te: పారిస్, am: ፓሪስ, is: París, sl: Pariz, es: París, hu: Párizs, ug: پارىژ,
// lb: Paräis, gn: Parĩ, za: Bahliz, br: Pariz, yo: Parisi, bo: ཕ་རི།, sv: Paris, ar: باريس, or: ପ୍ୟାରିସ, la: Lutetia, uz: Parij, so: Baariis, kk: Париж, ru: Париж, he:
// פריז, pa: ਪੈਰਿਸ, be: Парыж, my: ပါရီမြို့, ko: 파리, fa: پاریس, ps: پاريس, ca: París, cu: Парижь, et: Pariis, hr: Pariz, kn: ಪ್ಯಾರಿಸ್, nl: Parijs, hi: पैरिस, eo: Parizo,
// ja: パリ, yi: פאריז, no: Paris, ne: पेरिस, an: París, sh: Pariz, ba: Париж, wa: Paris, ka: პარიზი, tk: Pariž, sq: Parisi, zh: 巴黎, wo: Pari, mi: Parī, mr: पॅरिस,
// cv: Парис, el: Παρίσι, lv: Parīze, ga: Páras, ha: Pariis, ky: Париж, hy: Փարիզ, fi: Pariisi, tt: Париж, gl: París, zu: IParisi, eu: Paris, fr: Paris, os: Париж,
// ur: پیرس, ln: Pari, tg: Париж, ml: പാരിസ്, gu: પૅરિસ, uk: Париж, tl: Paris, vi: Paris, mn: Парис, lt: Paryžius, it: Parigi, bn: প্যারিস, oc: París, li: Paries, sk: Paríž},
// lat: 48.8588897, lon: 2.3200410217200766, country: FR, state: Ile-de-France}, {name: Paris, local_names: {af: Parys, cv: Парис, sv: Paris, za: Bahliz, it: Parigi,
// la: Lutetia, is: París, zh: 巴黎, fr: Paris, or: ପ୍ୟାରିସ, ko: 파리, pt: Paris, lb: Paräis, yo: Parisi, sq: Parisi, mr: पॅरिस, ka: პარიზი, an: París, ku: Parîs, ba: Париж,
// wo: Pari, so: Baariis, uk: Париж, de: Paris, bg: Париж, ln: Pari, tk: Pariž, zu: IParisi, oc: París, cs: Paříž, el: Παρίσι, ur: پیرس, yi: פאריז, be: Парыж, ar: باريس,
// kn: ಪ್ಯಾರಿಸ್, sc: Parigi, hy: Փարիզ, fi: Pariisi, lv: Parīze, ha: Pariis, bs: Pariz, sh: Pariz, kv: Париж, ht: Pari, co: Parighji, bo: ཕ་རི།, mi: Parī, es: París, bn: প্যারিস,
// ug: پارىژ, sr: Париз, en: Paris, ml: പാരിസ്, ru: Париж, ps: پاريس, kk: Париж, sl: Pariz, br: Pariz, gn: Parĩ, vi: Paris, mk: Париз, gu: પૅરિસ, am: ፓሪስ, hu: Párizs, km: ប៉ារីស,
// ta: பாரிஸ், tl: Paris, et: Pariis, gv: Paarys, ga: Páras, he: פריז, gd: Paras, mn: Парис, tt: Париж, pa: ਪੈਰਿਸ, fa: پاریس, my: ပါရီမြို့, ca: París, tg: Париж, os: Париж, hi: पैरिस,
// th: ปารีส, gl: París, ja: パリ, ne: पेरिस, li: Paries, eo: Parizo, sk: Paríž, cu: Парижь, eu: Paris, no: Paris, hr: Pariz, fy: Parys, lt: Paryžius, te: పారిస్, nl: Parijs,
// ky: Париж, pl: Paryż, uz: Parij}, lat: 48.8534951, lon: 2.3483915, country: FR, state: Ile-de-France}, {name: Paris, lat: 33.6617962, lon: -95.555513, country: US, state: Texas},
// {name: Paris, lat: 38.2097987, lon: -84.2529869, country: US, state: Kentucky}, {name: Paris, local_names: {ln: Pari, ja: パリ, th: ปารีส, ha: Pariis, te: పారిస్, lt: Paryžius, ta:
// பாரிஸ், ka: პარიზი, bo: ཕ་རི།, ar: باريس, cs: Paříž, sl: Pariz, tg: Париж, ht: Pari, km: ប៉ារីស, ur: پیرس, yi: פאריז, sv: Paris, ru: Париж, tl: Paris, lv: Parīze, cv: Парис, am: ፓሪስ,
// gn: Parĩ, hy: Փարիզ, zh: 巴黎, es: París, af: Parys, mk: Париз, sk: Paríž, ne: पेरिस, my: ပါရီမြို့, co: Parighji, no: Paris, uk: Париж, de: Paris, an: París, zu: IParisi, gu: પૅરિસ, oc: París,
// or: ପ୍ୟାରିସ, ca: París, os: Париж, be: Парыж, sr: Париз, sh: Pariz, fr: Paris, fa: پاریس, ga: Páras, kk: Париж, kn: ಪ್ಯಾರಿಸ್, sc: Parigi, uz: Parij, fy: Parys, vi: Paris, hr: Pariz,
// cu: Парижь, ky: Париж, la: Lutetia, it: Parigi, ko: 파리, lb: Paräis, ps: پاريس, he: פריז, br: Pariz, ba: Париж, ug: پارىژ, yo: Parisi, hu: Párizs, li: Paries, tk: Pariž, eo: Parizo,
// hi: पैरिस, mn: Парис, bn: প্যারিস, fi: Pariisi, mi: Parī, ku: Parîs, gv: Paarys, sq: Parisi, so: Baariis, bg: Париж, nl: Parijs, gl: París, pl: Paryż, ml: പാരിസ്, pa: ਪੈਰਿਸ, et: Pariis,
// za: Bahliz, mr: पॅरिस, wo: Pari, eu: Paris, el: Παρίσι, tt: Париж, is: París, kv: Париж, bs: Pariz}, lat: 48.8588897, lon: 2.3200410217200766,
// country: FR, state: Ile-de-France}]