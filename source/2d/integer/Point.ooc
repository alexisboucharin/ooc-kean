//
// Copyright (c) 2011-2014 Simon Mika <simon@mika.se>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.
import math
import Size
import ../../IntExtension
import text/StringTokenizer
import structs/ArrayList

Point: cover {
	x, y: Int
	init: func@ (=x, =y)
	init: func ~default { this init(0, 0) }
	scalarProduct: func (other: This) -> Int { this x * other x + this y + other y }
	//FIXME: Oddly enough, "this - other" instead of "this + (-other)" causes a compile error in the unary '-' operator below.
	swap: func -> This { This new(this y, this x) }
	minimum: func (ceiling: This) -> This { This new(this x minimum(ceiling x), this y minimum(ceiling y)) }
	maximum: func (floor: This) -> This { This new(this x maximum(floor x), this y maximum(floor y)) }
	clamp: func (floor, ceiling: This) -> This { This new(this x clamp(floor x, ceiling x), this y clamp(floor y, ceiling y)) }
	operator + (other: This) -> This { This new(this x + other x, this y + other y) }
	operator + (other: Size) -> This { This new(this x + other width, this y + other height) }
	operator - (other: This) -> This { This new(this x - other x, this y - other y) }
	operator - (other: Size) -> This { This new(this x - other width, this y - other height) }
	operator - -> This { This new(-this x, -this y) }
	operator * (other: This) -> This { This new(this x * other x, this y * other y) }
	operator * (other: Size) -> This { This new(this x * other width, this y * other height) }
	operator / (other: This) -> This { This new(this x / other x, this y / other y) }
	operator / (other: Size) -> This { This new(this x / other width, this y / other height) }
	operator * (other: Int) -> This { This new(this x * other, this y * other) }
	operator / (other: Int) -> This { This new(this x / other, this y / other) }
	operator == (other: This) -> Bool { this x == other x && this y == other y }
	operator != (other: This) -> Bool { this x != other x || this y != other y }
	operator < (other: This) -> Bool { this x < other x && this y < other y }
	operator > (other: This) -> Bool { this x > other x && this y > other y }
	operator <= (other: This) -> Bool { this x <= other x && this y <= other y }
	operator >= (other: This) -> Bool { this x >= other x && this y >= other y }
	operator as -> String { this toString() }
	toString: func -> String { "#{this x toString()}, #{this y toString()}" }
	parse: static func (input: String) -> This {
		array := input split(',')
		This new(array[0] toInt(), array[1] toInt())
	}
}
operator * (left: Int, right: Point) -> Point { Point new(left * right x, left * right y) }
operator / (left: Int, right: Point) -> Point { Point new(left / right x, left / right y) }
operator * (left: Float, right: Point) -> Point { Point new(left * right x, left * right y) }
operator / (left: Float, right: Point) -> Point { Point new(left / right x, left / right y) }
