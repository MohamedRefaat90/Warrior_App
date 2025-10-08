import 'package:Warrior/features/Home/data/repo/home_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Provider<HomeRepo> homeProvider = Provider<HomeRepo>(
  (ref) {
    //  ref.read(homeRepo).getAppVersion();
    return ref.read(homeRepo);
  },
);
