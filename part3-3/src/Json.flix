use List.foldLeft;
use Json.FromJson
use Json.JsonElement
use Json.JsonElement.JsonNull
use Json.JsonElement.JsonObject
use Json.JsonElement.JsonString
use Json.JsonError
use Json.Jsonable
use Json.ToJson
use Json.getAtKey;
use Json.getAtKeyOpt;
use Json.FromJson.fromJson
use Json.FromJson.fromJsonAt
use Json.FromJson.fromNullableJson
use Json.Path.Path
use Json.Path.Path.Root
use Json.ToJson.toJson

def readConfigFile(filename: String): Option[JsonElement] \ {FileReadWithResult} =
    match FileReadWithResult.read(filename) {
        case Ok(s) => Json.Parse.parse(s)
        case Err(_) => Some(JsonObject(Map#{}))
    }

def toEmpty(l : Result[_, List[a]]): List[a] =
    match l {
        case Ok(l1) => l1
        case Err(_) => Nil
    }

def getCharacters(): List[JsonElement] \ {FileReadWithResult} =
    let config = readConfigFile("../data/characters.json");
    match config {
      case None => Nil
      case Some(c) =>
        let result = forM (
                    map <- fromJsonAt(Root, c);
                    characters <- getAtKey(Root, "characters", map)
                ) yield {
                    characters
                };
        toEmpty(result)
    }

def getCharacterName(config: JsonElement): Result[JsonError,String] =
    forM (
        map <- fromJsonAt(Root, config);
        str <- getAtKey(Root, "characterName", map)
     ) yield str


def getParentOf(config: JsonElement): List[String] =
    let res = forM (map <- fromJsonAt(Root, config);
                    parents <- getAtKey(Root, "parentOf", map)) yield parents;
    toEmpty(res)

def getCharacterParentOf(config: JsonElement): List[(String, String)] =
    let result = getCharacterName(config);
    match result {
        case Ok(nm) => 
            foreach (p <- getParentOf(config)) 
                yield (nm, p)
        case Err(_) => Nil
    }


def getRelationship(relationship: String, config: JsonElement): List[String] =
    let result : Result[JsonError, List[String]] = forM (
        map <- fromJsonAt(Root, config);
        strList <- getAtKey(Root, relationship, map)
     ) yield strList;
    toEmpty(result)

def getCharacterRelationship(relationship: String, config: JsonElement): List[(String, String)] =
    let result = getCharacterName(config);
    match result {
        case Ok(nm) => 
            foreach (r <- getRelationship(relationship, config)) 
                yield (nm, r)
        case Err(_) => Nil
    }

pub def getRelationships(relationshipTypes: List[String]): List[(String, String)] \ {FileReadWithResult} =
    getCharacters() |> List.flatMap((c) -> relationshipTypes |> List.flatMap((rt) -> getCharacterRelationship(rt, c)))

pub def getParents(): List[(String, String)] \ {FileReadWithResult} =
    getCharacters() |> List.flatMap(getCharacterParentOf)