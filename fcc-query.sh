#!/usr/bin/env bash

# FCC callsign query by N5MAJ

# Copyright (c) 2017-2019 Michael A. Jarvis, All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the
#    distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived
#    from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

###################################################################33
# Configuration
###################################################################33
SEND_EMAIL=false                    # Change to true to send email
EMAIL_ADDRESS=                      # Your email address
EMAIL_NAME=                         # Your text name
FRN=                                # Your FCC Registration Number

###################################################################33
# END Configuration
###################################################################33

send_email()
{
    local mess=$1
    local MAIL_TO=${EMAIL_ADDRESS}

    local MY_EMAIL=$( ${MKTEMP} )
    trap "rm -vf ${MY_EMAIL}" 0 1 2 15

    printf "Date: %s\r\n" "$( ${DATE} -R )"  > ${MY_EMAIL}
    printf "From: %s <%s>\r\n" "${EMAIL_NAME}" "${EMAIL_ADDRESS}"  >> ${MY_EMAIL}
    printf "To: ${MAIL_TO}\r\n" >> ${MY_EMAIL}
    printf "Subject: Winner winner chicken dinner\r\n" >> ${MY_EMAIL}
    printf "\r\n" >> ${MY_EMAIL}
    printf "At %s:\r\n" "$( ${DATE} +%c)" >> ${MY_EMAIL}
    printf "%s\r\n" "${mess}" >> ${MY_EMAIL}

    ${SENDMAIL} -bm ${MAIL_TO} < ${MY_EMAIL}

}

shopt -s xpg_echo
# 30=black 31=red 32=green 33=yellow 34=blue 35=magenta 36=cyan 37=white
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    COLOR=true
    BLACK_ON="\e[30m"
    RED_ON="\e[31m"
    GREEN_ON="\e[32m"
    YELLOW_ON="\e[33m"
    BLUE_ON="\e[34m"
    MAGENTA_ON="\e[35m"
    CYAN_ON="\e[36m"
    WHITE_ON="\e[37m"
    BOLD_ON="\e[1m"
    COLOR_OFF="\e[0m"
fi

function errmsg()
{
    echo -ne "${RED_ON}" >&2
    echo -ne $1 >&2
    echo -e "${COLOR_OFF}" >&2
}

function warnmsg()
{
    echo -ne "${YELLOW_ON}" >&2
    echo -ne $1 >&2
    echo -e "${COLOR_OFF}" >&2
}

function infomsg()
{
    echo -ne "${GREEN_ON}"
    echo $1
    echo -e "${COLOR_OFF}"

}





echo -e "${WHITE_ON}-------------------------------------------------------------------------"
date
echo -e "${COLOR_OFF}"


OS=$( uname -s )
HOST=$( hostname -s )
case ${OS} in
    Darwin)
        # MacOS
        MKTEMP=/usr/bin/mktemp
        DATE=/bin/date
        CURL=/usr/local/opt/curl/bin/curl
        HTML2TEXT=/usr/local/bin/html2text
        if [[ -x /usr/local/bin/gawk ]]
        then
            AWK=/usr/local/bin/gawk
        else
            test -x /usr/bin/awk && AWK=/usr/bin/awk
        fi
        SENDMAIL=/usr/sbin/sendmail
        ;;

    Linux)
        MKTEMP=/bin/mktemp
        DATE=/bin/date
        CURL=/usr/bin/curl
        HTML2TEXT=/usr/bin/html2text
        AWK=/usr/bin/gawk
        SENDMAIL=/usr/bin/sendmail
        ;;

    *)
        errmsg "Operating system \"${WHITE_ON}${OS}${RED_ON}\" is not supported!"
        exit 1
        ;;
esac

# Sanity Checking
if [[ -z "${FRN}" ]]
then
    errmsg "Error! Must specify FCC Registration Number (FRN)!"
    errmsg "See https://apps.fcc.gov/coresWeb/publicHome.do"
    exit 1
fi


if [[ -z ${CURL} || ! -x ${CURL} ]]
then
    errmsg "ERROR! Cannot find ${CURL}"
    case ${OS} in
        Darwin)
            echo
            echo "If system curl does not work, try: brew install curl"
            echo "and use /usr/local/opt/curl/bin/curl"
            ;;
        Linux)
            echo "Depending on distribution, try either:"
            echo "sudo apt-get install curl"
            echo "-OR-"
            echo "sudo yum install curl"
            ;;
        *)
            echo "Unsupported operating system, you're on your own."
            ;;
    esac
    exit 1
fi

if [[ -z ${HTML2TEXT} || ! -x ${HTML2TEXT} ]]
then
    errmsg "ERROR! Cannot find ${HTML2TEXT}"
    case ${OS} in
        Darwin)
            echo
            echo "Try:"
            echo
            echo "    brew install html2text"
            ;;
        Linux)
            echo "Depending on distribution, try either:"
            echo
            echo "    sudo apt-get install html2text"
            echo
            echo "-OR-"
            echo
            echo "    sudo yum install html2text"
            ;;
        *)
            echo "Unsupported operating system, you're on your own."
            ;;
    esac
    exit 1
fi

if [[ -z ${AWK} || ! -x ${AWK} ]]
then
    errmsg "ERROR! Cannot find ${AWK}!"
    case ${OS} in
        Darwin)
            echo
            echo "Try:"
            echo
            echo "    brew install gawk"
            ;;
        Linux)
            echo "Depending on distribution, try either:"
            echo
            echo "    sudo apt-get install gawk"
            echo
            echo "-OR-"
            echo
            echo "    sudo yum install gawk"
            ;;
        *)
            echo "Unsupported operating system, you're on your own."
            ;;
    esac
    exit 1
fi

RAW_TEMP=$( ${MKTEMP} )
trap "rm -vf ${RAW_TEMP}" 0 1 2 15

${CURL} -s -L \
    -A 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_1) AppleWebKit/604.3.5 (KHTML, like Gecko) Version/11.0.1 Safari/604.3.5' \
    -H 'Accept-Language: en-us' \
    -e 'https://wireless2.fcc.gov/UlsApp/UlsSearch/searchLicense.jsp' \
    --data-urlencode "fiUlsSearchByType=uls_l_frn" \
    --data-urlencode "fiUlsSearchByValue=${FRN}" \
    --data-urlencode "fiUlsExactMatchInd=Y" \
    --data-urlencode "hiddenForm=hiddenForm" \
    --data-urlencode "jsValidated=true" \
    https://wireless2.fcc.gov/UlsApp/UlsSearch/results.jsp \
    | ${HTML2TEXT} -nobs -width 150 -style compact -ascii > "${RAW_TEMP}"

echo -e "${BLACK_ON}${BOLD_ON}"
cat ${RAW_TEMP}
echo -e "${COLOR_OFF}"

RESULT="$( cat ${RAW_TEMP} | ${AWK} ' /Active/ { print $0 } /No matches found/ { print "No matches found" }' )"


echo
if [[ ${RESULT} =~ "Active" ]]
then
    if [[ "${SEND_EMAIL}" == true ]]; then
        warnmsg "Sending email..."
        send_email "${RESULT}"
    else
        warnmsg "NOT sending email..."
    fi
    echo -e "${GREEN_ON}"
else
    echo -e "${RED_ON}"
fi

if [[ -z ${RESULT} ]]; then
    echo "Nothing found"
else
    echo "${RESULT}"
fi

echo -e "${COLOR_OFF}"

