//----------------------------------------------------------------------------
// Anti-Grain Geometry - Version 2.4
// Copyright (C) 2002-2005 Maxim Shemanarev (http://www.antigrain.com)
//
// Permission to copy, use, modify, sell and distribute this software 
// is granted provided this copyright notice appears in all copies. 
// This software is provided "as is" without express or implied
// warranty, and with no claim as to its suitability for any purpose.
//
// Haxe port by: Hypeartist hypeartist@gmail.com
// Copyright (C) 2011 https://code.google.com/p/aggx
//
//----------------------------------------------------------------------------
// Contact: mcseem@antigrain.com
//          mcseemagg@yahoo.com
//          http://www.antigrain.com
//----------------------------------------------------------------------------

package lib.ha.core.memory;
//=======================================================================================================
import lib.ha.core.utils.Debug;
import types.Data;
//=======================================================================================================
private typedef MemoryBlockFriend =
{
	private var _start:UInt;
	private var _size:UInt;
	private var _ptr:Pointer;
	private var _prev:MemoryBlock;
	private var _next:MemoryBlock;
}
//=======================================================================================================
class MemoryManager
{
	private static var _lastBlock:MemoryBlockFriend;
	private static var blocks:Array<MemoryBlock> = new Array();
	//---------------------------------------------------------------------------------------------------
	public static function malloc(?size:Int):MemoryBlock
	{
		if (size == null || size < 1024)
		{
			size = 1024;
		}
		var block = new MemoryBlock();
		mallocImpl(size, block);
		_lastBlock = block;
		var caller = Debug.calledFrom();
        trace('malloc:($size): ${block.ptr}[${block.size}] caler: ${caller}');
		return block;
	}
	//---------------------------------------------------------------------------------------------------
	public static function mallocEx(bytes:Data):MemoryBlock
	{
		if (bytes.allocedLength < 1024)// TODO Check
		{
			bytes.resize(1024);
		}
		var block = new MemoryBlock();
		mallocExImpl(bytes, block);
		_lastBlock = block;
		var caller = Debug.calledFrom();
		trace('mallocEx:(${bytes.allocedLength}): ${block.ptr}[${block.size}]  caler: ${caller}');
		return block;
	}	
	//---------------------------------------------------------------------------------------------------
	private static function realloc(block:MemoryBlockFriend, size:UInt):Void
	{
		size = roundToNext1024(size);
		if (size != block._size)
		{
			var offset = size-block._size;
			block._size = size;
			var prev:MemoryBlockFriend = _lastBlock;
            MemoryAccess.resizeOffset(offset);
			while (prev._start != block._start)
			{
				MemoryUtils.copy(prev._start + offset, prev._start, prev._size);
				prev = prev._prev;
			}
			block._ptr = block._size;
		}
	}
	//---------------------------------------------------------------------------------------------------
	private static function expand(block:MemoryBlockFriend, size:UInt):Void
	{
		size = roundToNext1024(size);
		if (size > 0)
		{
			var offset = size;
			block._size += size;
			var prev:MemoryBlockFriend = _lastBlock;
            MemoryAccess.resizeOffset(offset);
			while (prev._start != block._start)
			{
				MemoryUtils.copy(prev._start + offset, prev._start, prev._size);
				prev = prev._prev;
			}
			block._ptr = block._size;
		}
	}	
	//---------------------------------------------------------------------------------------------------
	private static function free(block:MemoryBlockFriend):Void
	{
		var prev:MemoryBlockFriend = block._prev;
		var next:MemoryBlockFriend = block._next;
		prev._next = cast next;
		next._prev = cast prev;
		var offset = -block._size;
		while (next != null)
		{
			MemoryUtils.copy(next._ptr + offset, next._ptr, next._size);
			next = next._next;
		}
        MemoryAccess.resizeOffset(offset);
	}
	//---------------------------------------------------------------------------------------------------
	private static function mallocImpl(size:Int, block:MemoryBlockFriend):Void
	{
		size = roundToNext1024(size);
		if (_lastBlock == null) 
		{
			var bytes = new Data(size);
			MemoryAccess.select(bytes);
			block._start = block._ptr = 0;
			block._size = size;
			_lastBlock = block;
		}
		else 
		{
			_lastBlock._next = cast block;
			block._prev = cast _lastBlock;
			block._start = block._ptr = _lastBlock._start + _lastBlock._size;
			block._size = size;
			_lastBlock = block;
            MemoryAccess.resizeOffset(size);
		}
	}
	//---------------------------------------------------------------------------------------------------
	private static function mallocExImpl(bytes:Data, block:MemoryBlockFriend):Void
	{
		if (_lastBlock == null)
		{
			MemoryAccess.select(bytes);
			block._start = block._ptr = 0;
			block._size = bytes.allocedLength;
			_lastBlock = block;
		}
		else 
		{
			_lastBlock._next = cast block;
			block._prev = cast _lastBlock;
			block._start = block._ptr = _lastBlock._start + _lastBlock._size;
			block._size = bytes.allocedLength;
			_lastBlock = block;
            MemoryAccess.resizeOffset(bytes.allocedLength);
            MemoryAccess.writeBytes(bytes, block._start, block._size);
		}
	}	
	//---------------------------------------------------------------------------------------------------
	private static inline function roundToNext1024(size:UInt):UInt
	{
        var remainder: UInt = size % 1024;
        if (remainder == 0) return size;
        return size + 1024 - remainder;
	}
}