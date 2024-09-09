import 'package:flutter/material.dart';

class MyColors {
  static const Color primaryColor = Color(0xFF4C3BCF);
  static const Color buttonColor = Color(0xFF4B70F5);
}

//* filtreleme alanında kullanılacak olan sabitler
class BookVariables {
  //* Kitap Türlerinin Listesi
  final List<String> genres = [
    "Roman",
    "Kişisel Gelişim",
    "Tarih",
    "Biyografi",
    "Felsefe",
    "Psikoloji",
    "Bilim Kurgu ve Fantastik",
    "Çizgi Roman",
    "Çocuk",
    "Din",
    "Mizah",
    "Mühendislik",
    "Sağlık",
    "Siyaset",
    "Öykü"
        "Dünya Edebiyatı",
    "Kurgu",
    "Distopya",
    "Deneme",
    "Polisiye"
  ];

//* Kitabın okunduğu yılları tutan liste
  final List<int> years = [2018, 2019, 2020, 2021, 2022, 2023, 2024];

//* Kitap Dillerinin Listesi
  final List<String> languages = ["Türkçe", "İngilizce"];
}
