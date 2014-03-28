# NSKeyedArchiver+butWithNSError

NSKeyedArchiver+butWithNSError is a very small project that provides two categories: one on `NSKeyedArchiver` and one on `NSKeyedUnarchiver`:

	@interface NSKeyedArchiver (butWithNSError)
	+ (NSData*)jr_archivedDataWithRootObject:(id)rootObject
						requiresSecureCoding:(BOOL)requiresSecureCoding
									   error:(NSError**)error
	@end

	@interface NSKeyedUnarchiver (butWithNSError)
	+ (id)jr_unarchiveData:(NSData*)data
	  requiresSecureCoding:(BOOL)requiresSecureCoding
				 whitelist:(NSArray*)customClassWhitelist
					 error:(NSError**)error;
	@end

These categories make it easier to use NSKeyedArchiver and NSKeyedUnarchiver correctly, securely and cope with the fact NSKeyedUnarchiver throws exceptions.

These should be compatible with both ARC and MRC.

## Use

The categories are mostly self-evident.

Call `+[NSKeyedArchiver(butWithNSError) jr_archivedDataWithRootObject:requiresSecureCoding:error:]` to serialize `rootObject`'s object graph into an `NSData`. Set `requiresSecureCoding` to `YES` if you want an error returned if any object doesn't support `NSSecureCoding`.

Call `+[NSKeyedUnarchiver(butWithNSError) jr_unarchiveData:requiresSecureCoding:whitelist:error:]` to deserialize the data back into objects. `requiresSecureCoding` works the same way as above.

`whitelist` can be nil or empty, but if supplied will be added to the list of trusted classes allowed to be deserialized. Naturally these classes must support `NSSecureCoding` otherwise you'll get a runtime error.

The Plist-standard are automatically whitelisted for you: NSArray, NSDictionary, NSString, NSNumber, NSDate, NSData.

## Ease

In the Good Old Days, you'd call

	+[NSKeyedArchiver archivedDataWithRootObject:]

and

	+[NSKeyedUnarchiver unarchiveObjectWithData:]

and would be done for the day and catch an X-Files rerun. I hope the Smoking Man's in this one.

But then [NSSecureCoding](http://nshipster.com/nssecurecoding/) burst onto the scene. Now you need to manually create your archivers and unarchives just so you can call their concealed `-setRequiresSecureCoding:` methods.

Not only are you now in the creation and configuration business, you need to use it correctly. And it turns out there's a trap for the unwary.

Having to reimplement `+archivedDataWithRootObject:`, you'd be forgiven thinking that you should utilize `-[NSKeyedArchiver encodeRootObject:]`. That's what I did.

Bzzt. Unfortunately it turns out generates a binary plist in a format (I call this "format 1") that's incompatible with `+[NSKeyedUnarchiver unarchiveObjectWithData:]` (which requires what I call "format 2").

Here's a table of which methods play with which format. I think.

Method                                                                 | Binary Plist Format  | NSSecureCoding compatible
---                                                                    | ---                  | ---
`-[NSKeyedArchiver encodeRootObject:]`                                 | Format 1             | no
`-[NSKeyedUnarchiver decodeObject]`                                    | Format 1             | no
`+[NSKeyedArchiver archivedDataWithRootObject:]`                       | Format 2             | no
`+[NSKeyedUnarchiver unarchiveObjectWithData:]`                        | Format 2             | no
`-[NSKeyedArchiver encodeObject:forKey:NSKeyedArchiveRootObjectKey]`   | Format 2             | yes
`-[NSKeyedUnarchiver decodeObjectForKey:NSKeyedArchiveRootObjectKey]`  | Format 2             | yes

The Bad News since is that you must use `-[NSKeyedUnarchiver decodeObject]` to decode what `-[NSKeyedArchiver encodeRootObject:]` is cooking, and `-decodeObject` isn't compatible with NSSecureCoding (you need to use `-decodeObjectOfClasses:forKey:`).

**tl;dr**: don't use `-[NSKeyedArchiver encodeRootObject:]` or `-[NSKeyedUnarchiver decodeObject]` in new code unless you need compatibility with Format 1 archives.

Since `+[NSKeyedArchiver archivedDataWithRootObject:]` and `+[NSKeyedUnarchiver unarchiveObjectWithData:]` don't give you an opportunity to call `-setRequiresSecureCoding:YES`, they're out of the party as well.

That leaves us with `-[NSKeyedArchiver encodeObject:forKey:NSKeyedArchiveRootObjectKey]` and `-[NSKeyedUnarchiver decodeObjectForKey:NSKeyedArchiveRootObjectKey]`. Which is what NSKeyedArchiver+butWithNSError uses.

## NSError\*\*

I could make a case for NSKeyedArchiver throwing exceptions since as the programmer you can know what you're passing it. But it seems wrong that NSKeyedUnarchiver throws exceptions.

Here is a class responsible for decoding potentially hostile data and it blow up your entire process if things aren't exactly to its liking?! That's just nuts.

NSKeyedArchiver+butWithNSError catches exceptions, unravels them and transmogrifies them into NSErrors for you so you can handle them normally (I'm biased, but I recommend [JRErr](https://github.com/rentzsch/JRErr)).

## TODO

Promote to v1.0 when I ship.

## Version History

### v1.0b1: Mar 28 2014

* Initial release.