module common;

import raylib;
import animation;
import std::collections::map;
import std::collections::list;

import log;

alias Color   = char[<4>];
alias Vector2 = float[<2>];

const Color WHITE = { 255, 255, 255, 255 };
const Color RED   = { 255,   0,   0, 255 };

macro Rectangle Rectangle.shrink(rectangle, float n) {
    return {
        .x      = rectangle.x + n,
        .y      = rectangle.y + n,
        .width  = rectangle.width  - n*2,
        .height = rectangle.height - n*2,
    };
}

struct SpriteData {
    String    filename;
    Texture2D texture;
    Image     image;
    bool      needs_flip;
}

List{SpriteData} sprite_data_list = list::ONHEAP{SpriteData};

alias SpriteDataIndex = usz;

macro SpriteDataIndex push_sprite_data(SpriteData data) {
    sprite_data_list.push(data);
    return sprite_data_list.len() - 1;
}


struct MusicData {
    Music  music;
    String name;
    String filename;
}

List{MusicData} music_data_list = list::ONHEAP{MusicData};

alias MusicDataIndex = usz;

const MusicDataIndex NO_MUSIC = ~0;

MusicDataIndex current_music = NO_MUSIC;

fn bool music_exists(String name) {
    foreach(MusicData music_data : music_data_list) {
        if(music_data.name == name) return true;
    }

    return false;
}
faultdef MUSIC_NOT_FOUND;

fn MusicDataIndex? get_music_index_by_name(String name) {
    for(MusicDataIndex i = 0; i < music_data_list.len(); i++) {
        if(music_data_list[i].name == name) return i;
    }

    return MUSIC_NOT_FOUND?;
}

enum Direction : char (String value) {
    LEFT  = "left",
    RIGHT = "right"
}

macro Direction.flip(d) => d == Direction.LEFT ? Direction.RIGHT : Direction.LEFT;

const Direction DEFAULT_DIRECTION = Direction.LEFT;

struct Character {
    Vector2   position;
    bool      visible;
    String    current_emotion;
    String    name;
    Direction direction;

    HashMap{String, SpriteDataIndex} emotion_sprite_table;
}

alias CharacterIndex = uint;
List{Character} characters;
HashMap{String, CharacterIndex} character_name_table;

macro Character* get_character_by_name(String name) {
    return &characters[common::character_name_table[name]!!];
}

bool animaton_enabled = true;

const AnimationIndex IDLE_ANIMATION = 0;

AnimationIndex current_animation = IDLE_ANIMATION;

const SpriteDataIndex INVALID_BACKGROUND = ~0;
SpriteDataIndex current_background = INVALID_BACKGROUND;

HashMap{String, SpriteDataIndex} background_name_table;

macro bool background_exists(String name) {
    return background_name_table.has_key(name);
}

const usz MAX_TEXT_SIZE = 1024;
char[MAX_TEXT_SIZE] message_box_buffer;

const float FONT_SIZE    = 18.0;
const float TEXT_PADDING = 10.0;
const float LINE_SPACING =  5.0;

struct TextAnimation {
    float duration;
    float step;
    String text;
    String said_by;
}

bool show_text_box = true;

TextAnimation text = {
    .duration = 0.35,
    .step     = 0.0,
    .text     = "",
    .said_by  = ""
};

macro void @print_type_tree(#type, uint recursion_level = 0) {
    const String SPACES = "  .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   . ";

    log::debug("%.*s%s: %d.", recursion_level * 4, SPACES, #type.nameof == "" ? "anonymous field" : #type.nameof, #type.sizeof);

    $foreach $field : #type.membersof:
        $if $field.nameof == "":
            @print_type_tree($field, recursion_level + 1);
        $else
            log::debug("%.*s%s: %d", (recursion_level+1) * 4, SPACES, $field.nameof, $field.sizeof);
        $endif
    $endforeach
}
