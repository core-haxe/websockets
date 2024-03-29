// !!!! utest/Async.hx SHADOWED FILE!!!!
// utest uses haxe.Timer for its timeout, this breaks on jvm, so this version has a flag "no_timer" that enables it to be "removed"
// note, this also means that things will _never_ timeout... 

package utest;

#if (haxe_ver < "3.4.0")
	#error 'Haxe 3.4.0 or later is required for utest.Async'
#end

import haxe.PosInfos;
#if !no_timer
import haxe.Timer;
#end

@:allow(utest)
class Async {
	static var resolvedInstance:Async;

	public var resolved(default,null):Bool = false;
	public var timedOut(default,null):Bool = false;

	var callbacks:Array<Void->Void> = [];
	var timeoutMs:Int;
	var startTime:Float;
    #if !no_timer
	var timer:Timer;
    #end
	var branches:Array<Async> = [];

	/**
	 * Returns an instance of `Async` which is already resolved.
	 * Any actions handling this instance will be executed synchronously.
	 */
	static function getResolved():Async {
		if(resolvedInstance == null) {
			resolvedInstance = new Async();
			resolvedInstance.done();
		}
		return resolvedInstance;
	}

	function new(timeoutMs:Int = 250) {
		this.timeoutMs = timeoutMs;
        #if !no_timer
		startTime = Timer.stamp();
		timer = Timer.delay(setTimedOutState, timeoutMs);
        #end
	}

	public function done(?pos:PosInfos) {
		if(resolved) {
			if(timedOut) {
				throw 'Cannot done() at ${pos.fileName}:${pos.lineNumber} because async is timed out.';
			} else {
				throw 'Cannot done() at ${pos.fileName}:${pos.lineNumber} because async is done already.';
			}
		}
		resolved = true;
        #if !no_timer
		timer.stop();
        #end
		for (cb in callbacks) cb();
	}

	/**
	 * Change timeout for this async.
	 */
	public function setTimeout(timeoutMs:Int, ?pos:PosInfos) {
		if(resolved) {
			throw 'Cannot setTimeout($timeoutMs) at ${pos.fileName}:${pos.lineNumber} because async is done.';
		}
		if(timedOut) {
			throw 'Cannot setTimeout($timeoutMs) at ${pos.fileName}:${pos.lineNumber} because async is timed out.';
		}

        #if !no_timer
		timer.stop();

		this.timeoutMs = timeoutMs;
		var delay = timeoutMs - Math.round(1000 * (Timer.stamp() - startTime));
		timer = Timer.delay(setTimedOutState, delay);
        #end
	}

	/**
		Create a sub-async. Current `Async` instance will be resolved automatically once all sub-asyncs are resolved.
	**/
	public function branch(?fn:Async->Void, ?pos:PosInfos):Async {
		var branch = new Async(timeoutMs);
		branches.push(branch);
		branch.then(checkBranches.bind(pos));
		if(fn != null) fn(branch);
		return branch;
	}

	function checkBranches(pos:PosInfos) {
		if(resolved) return;
		for(branch in branches) {
			if(!branch.resolved) return;
			if(branch.timedOut) {
				setTimedOutState();
				return;
			}
		}
		//wait, maybe other branches are about to be created
		var branchCount = branches.length;
        #if !no_timer
		Timer.delay(
			function() {
				if(branchCount == branches.length) { // no new branches have been spawned
					done(pos);
				}
			},
			5
		);
        #end
	}

	function then(cb:Void->Void) {
		if(resolved) {
			cb();
		} else {
			callbacks.push(cb);
		}
	}

	function setTimedOutState() {
		if(resolved) return;
		timedOut = true;
		done();
	}
}