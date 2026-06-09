import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pandemic_game/cloud/firebase.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DecisionTree {
  late Map<String, dynamic> tree;
  String currentNode = "start";

  // retrieve decision tree
  Future<void> getTree(String path) async {
    try {
    await fetchGameData();
    final box = Hive.box('gameData');

    if (box.containsKey('firebaseData')) {
      final data = Map<String, dynamic>.from(box.get('firebaseData'));
      tree = data;
      print("from hive yeah");
    } else {
      String jsonString = await rootBundle.loadString(path);
      tree = jsonDecode(jsonString);
      print("from assets");
    }
    } catch (e) {
      print("falling back to assets: $e");
      String jsonString = await rootBundle.loadString(path);
      tree = jsonDecode(jsonString);
    }
  }

  String getCurrentDescription() {
    return tree[currentNode]["description"];
  }

  Map<String, String> getCurrentChoices() {
    return Map<String, String>.from(tree[currentNode]["choices"]);
  }

  void setCurrentNode(choice) {
    currentNode = choice;
  }

  int returnPopulationEffect() {
    return tree[currentNode]["actions"]["population"];
  }

  int returnResourceEffect(resourceEffect) {
    return tree[currentNode]["actions"][resourceEffect];
  }

  bool isNodeGreaterThan(String currentNode) {
    return currentNode.compareTo("nodeY") > 0;
  }

  int returnEconomyEffect(country) {
    return tree[currentNode]["actions"][country];
  }
}

void updateCountry(currentTree, resourceEffect, economyEffect,
    population, countryResource, countryEconomy) {
  int recovered = currentTree.returnPopulationEffect();
  int resource = currentTree.returnResourceEffect(resourceEffect);
  int economy = currentTree.returnEconomyEffect(economyEffect);
  population.increasePopulation(recovered);
  countryResource.updateResource(resource);
  countryEconomy.updateEconomy(economy);
}