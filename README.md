# Impatient-Ham

## Description

This shell script is intended for people in the United States of
America who recently passed their FCC exam(s) to obtain their amateur
radio license.

The script works by querying the FCC database for your FRN, using
[curl](https://curl.haxx.se), and checking for the word "Active". If
that word is detected, it sends you an email.

The idea is to automatically run this script several times per day,
and it will notify you when your call sign is active. I originally
wrote this when I obtained MY license in late 2017, and I received
notice of my call sign almost a full twelve hours before I received
the "official" email from the FCC.

If you're wondering why you should go to the trouble of doing this,
just to save twelve hours, then this script is probably not for you!

## Disclaimer

*I am not responsible for abuse of this script!*

Please be courteous and do not hammer the FCC website! In my opinion,
there is no need to query more than once per hour, max. If too many
people start using this script irresponsibly, then the FCC may take
measures to block access, and we don't want that.

Also, be sure and turn this off once your call sign is active. There's
no need to keep wasting bandwidth once your call sign is live.

## Requirements

First of all you will need your [FCC Registration Number, or FRN](https://apps.fcc.gov/coresWeb/publicHome.do).
If you applied for your amateur radio license using just your social
security number, then this script will not work for you, since your
FRN will be assigned at the same time your license is granted. You may
be able to modify this script to detect your call sign using your full
name, but your mileage may vary, depending upon how common your name
is. You cannot search the FCC database by Social Security Number.

Secondly, you will need a UNIX-like operating system such as Linux,
FreeBSD, OpenBSD, NetBSD, macOS, Solaris, etc. You may be able to get
this working with the Windows 10 Linux stuff, and please let me know
if you do.

You will also need the following utilities:

* [curl](https://curl.haxx.se)
* [html2text](https://pypi.org/project/html2text/), which requires [python](https://python.org)
* [awk](https://www.gnu.org/software/gawk/): Link goes to GNU Awk, but other variants should work fine
* [sendmail](https://en.wikipedia.org/wiki/Sendmail) Note that the actual Sendmail is not required--you can use Postfix or any other reasonable MTA that supports a sendmail-like interface
* Some method of scheduling the job such as `cron(1)`

## Configuration

I wrote this for my own use, but it is easily configurable. At the
top, edit the script and put your FRN, as well as your email address
and your name.

## Future plans

I may eventually rewrite this in some other programming language, such
as [Go](https://golang.org/), just so that it's not so kludgey.

