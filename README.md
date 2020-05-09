# CS50x's final project : FreeCell

## Introduction

### CS50x

CS50x is an online course proposed by HarvardX, available on the edX's platform.
Harvard University offers free online courses, as CS50x, which is an
>introduction to the intellectual enterprises of computer science and the art of programming. This course teaches students how to think algorithmically and solve problems efficiently. Topics include abstraction, algorithms, data structures, encapsulation, resource management, security, and software engineering. Languages include C, Python, and SQL plus students’ choice of: HTML, CSS, and JavaScript (for web development); Java or Swift (for mobile app development); or Lua (for game development). Problem sets inspired by the arts, humanities, social sciences, and sciences. Course culminates in a final project. 

For more information see :
* [CS50x on edX](https://courses.edx.org/courses/course-v1:HarvardX+CS50+X/course/)
* [HarvardX on edX](https://www.edx.org/school/harvardx)
* [CS50x](https://cs50.harvard.edu/x/2020/)
* [CS50x's final project](https://cs50.harvard.edu/x/2020/project/)

### FreeCell for computer

FreeCell is a patience card game played using a 52-card deck, for it's [rules](#Rules). 

The FreeCell game was first implemented for computers in 1978 for the PLATO computer system (see [PLATO](https://en.wikipedia.org/wiki/PLATO_(computer_system))), and has been included in most Windows operating system since 1995, which is the cause of it's popularity.

Until 2006 (Microsoft Vista), the Microsoft FreeCell was limited in it's player assistance features, such as retraction of moves. After 2006, the game offered basic hints and unlimited move retraction, and the option to restart the game.

According to Microsoft's telemetry, FreeCell was the seventh most-used Windows program.

The version of FreeCell I propose [here](https://github.com/ncaparros/FreeCell) is a basic implementation of that very popular solitaire game. My goal was to have a functional program observing all the [rules](#Rules) in order to practice :
* Implementing [Lua](#Lua)'s programming language
* Developing a full game [logic](#Structures) 
* Working with [objects](#Classes)
* Working with [sprites](#Sprites)
* Working with [nodes](#Nodes)

### Lua

[Lua](https://www.lua.org/about.html) is a free, open-source, lightweight, high-level, cross-platform programming language created in 1993. It supports amongst other object-oriented programming, which is extremely convenient for game developing.

### Löve

[Löve](https://love2d.org/) is a free, open-source, cross-platform engine used to make 2D games in [Lua](#Lua). It is designed in C++ and frequently used in video game development competitions.

## Rules

The game is composed of :
* Four open foundations (called Home Cells here)
* Four open cells (called Free Cells here)
* A board

All cards are randomly dealt face-up from at the begining of the game into eight cascades, half of them composed by seven cards, the other half by six, on the board. 

The goal is form full suits in order (starting with ace, ending with king) into open foundations (called "Home Cells" here). 

The player is allowed to build tableaux on the board, alternating colors and decreasing the card value by one as he goes.

Examples of valid tableaux :
* 1. King of spades
    2. Queen of hearts
    3. Jack of clubs
    4. Ten of diamonds
    5. Nine of clubs
    6. End of tableau
<br/>
<br/>
* 1. Six of spades
    2. Five of diamonds
    3. Four of spades
    4. Three of hearts
    5. End of tableau

Cards may be stored on open cells (one and only card on one open cell).

When a pile of cards on the board is empty, it becomes an open cell and cards can be stacked back on it.

Technically, the player is only allowed to move cards one by one, but to simplify the game experience, it is possible to move as many cards on a tableau as there are free cells plus one.
Examples : 
* If there is no free open cell, cards must be moved one by one
* If there is one open cell, cards may be moved two by two (if in tableau)
    * It is the equivalent of moving top card to free cell, then second card to destination, and moving back top card on second card
* If there is one open cell and one empty pile on the board, cards may be moved three by three
    * It is the same as having two empty open cells
    * It is the equivalent of moving top card to free cell, second card to empty pile, third card to destination, second card on third card, and top card back on second card

The game is won when all the cards are stack in suits in the foundation cells.

Not all deals are solvable.

## Features

### Random deal

Every deal is unique. There are 52 factorial ($8*10^{67}$)

### Moving one card

### Moving several cards

### Moving restrictions

### Auto-Complete

## Structures

### Classes

### Sprites

### Deal

### Nodes

### Locking cards

### Managing Moves

### Managing Free Cells

### Managing Home Cells

### Managing Auto-Complete

## Demo

## Openings

## References

[CS50x](https://cs50.harvard.edu/x/2020/)
[CS50x on edX](https://courses.edx.org/courses/course-v1:HarvardX+CS50+X/course/)
[CS50x's final project](https://cs50.harvard.edu/x/2020/project/)
[FreeCell](https://en.wikipedia.org/wiki/FreeCell)
[HarvardX on edX](https://www.edx.org/school/harvardx)
[Microsoft FreeCell](https://en.wikipedia.org/wiki/Microsoft_FreeCell)
[PLATO](https://en.wikipedia.org/wiki/PLATO_(computer_system))

## About the author