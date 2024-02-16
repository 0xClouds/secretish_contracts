//SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
  ___        ____ _                 _                                 
 / _ \__  __/ ___| | ___  _   _  __| |___                             
| | | \ \/ / |   | |/ _ \| | | |/ _` / __|                            
| |_| |>  <| |___| | (_) | |_| | (_| \__ \                            
 \___//_/\_\\____|_|\___/ \__,_|\__,_|___/    ____ ___ _____ _____    
/ ___|  ___  ___ _ __ ___| |_(_)___| |__     / ___|_ _|  ___|_   _|__ 
\___ \ / _ \/ __| '__/ _ \ __| / __| '_ \   | |  _ | || |_    | |/ __|
 ___) |  __/ (__| | |  __/ |_| \__ \ | | |  | |_| || ||  _|   | |\__ \
|____/ \___|\___|_|  \___|\__|_|___/_| |_|___\____|___|_|     |_||___/
                                        |_____|                       
                                        
 ----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------+#++++++----------------------------------------------------------------------
-------------------++++++.++++-+###-----------------------------------------------------------------
------------------#+-++++++++++++++--+++------------------------------------------------------------
----------------+#--..--+++++++++--++++++++---------------------------------------------------------
---------------+##+....+++++++.......-++++++++------------------------------------------------------
--------------+###+-++-+######+.....++++++++-.-+----------------------------------------------------
-------------+################+--+-.+++++++-. ...+--------------------------------------------------
-------------##+-.############++++++++-.-++-.-..+++#------------------------------------------------
------------+#-....-+########+++++++++++++++++++++++++----------------------------------------------
------------+##+.-.###+----######+++++++++++++--.-----+-..........----------------------------------
------------+#####+##-------+##++####+++......--++###+++--++#################+----------------------
------------+#######+-------+######++-...--+##+++---+++++++++++++++++++++++++--++-------------------
------------+######+--------+####+----++##+++++++++++++++++++#####################+-----------------
----++-----+#######------..+###---++##+++++++++++++--+############################+-.---------------
-----+###########-------...-#-++#####++++++++++++##+----+########################..-----------------
-------+#######+------.....-######+++++++++++#######++---....-+################+-...----------------
---------------------.....-####+++++++++####################+-..+############+.......---------------
--------------------....+###+++++++###+-+#####################+.+##########+..........--------------
-----------------.--..+####++++######++-#++###################+.+########+.............-------------
-------------------.-###+++########+++-++.-#######++##########+.+#####+-................------------
-----------------.-##############+++++-#-.-#####++--#####-####+.+###-....................--.--------
-----------------###############+++++-##-.-######-...##+-.-###+.++.........................---------
---------------################++++++-#+-.-######-#++###+..-##+.++...............-...........-------
--------------##################+++++-#+-.-############+-#++##+.-+-.............##-  .-#......------
-------------+#################++++++-#+-.-###################+.-+-............-##...+#+. .....-----
-------------+###########+--###++++++-#+-.-###################+-#+-............##...+##........-----
------------------........-####++++++-#+-.-###################+-#+-............##--##-..-##....-----
------------------........#####++++++-#+-....--++#############+-#+-...-##+...-#######-+###.....-----
-------------------.......######+++++-#+-..--.............--+++-#+-....-##+.+##########+.......-----
------------------.........+#####++++-#+-.++--.....-####-......-#+-.....+#################+....-----
-------------------..........####++++-##--..........----..---+-+#+-......+##########+----....-------
-------------------.......-#######+++-######+++++++++----------+++........+########+........--------
-------------------.....-##########++++########################++.........+#######........----------
--------------------...-###########+++-###+++++++###########+++-.........-#-+###+-......------------
---------------------+###############++-###-+----+######+++-............+###+++++-..----------------
-------------------####################++-###########+-+#-.............+-+######+-..----------------
-----------------+######++++++####++++####+-+#####+++####+--..........-+.+##++++#+------------------
----------------+######++++++++++#####+++++##+-+++##+##+++---........-+-.+###+++#-+-----------------
----------------+######+++++#+++++++++#####+-####+###++++++-++......-++-.+#######+------------------
----------------#######++++++++++++++++++####+---##+++++++++++-..----#--.+#######+------------------
---------------+####+++++++++##+++++++++++++#+-#-#++++++#++++#+-----+#--.+#######+------------------
--------------#########++++++##+++++++++++++#+-#-+++++++#+#++++--++###--.+#######+------------------
--------------########+++++++###++++++++++++#+-#-+++++++###+++++#+###+--.+#######+------------------
--------------########+++++++####++++++++++++.-#-.#+++++###+++##++###+-..+#######-+-----------------
-------------+#########++++++#####++++++++++######++++++###++##++####+-..+#######.#-----------------
-------------##########+++++########++++++++++#+++++++++#############+-..+#######.#-----------------
-------------########+++++++#########+++++++++++++++++++##############--.+#######.#-----------------
------------+#########++++++###########+++++++++++++++++##############--.+#######.#-----------------
------------###########+++++############++++++++++++++++##############--.+#######.#-----------------                         
 */

error NOT_ENOUGH_ETHER_SENT();
error ALREADY_GAVE_A_GIFT();

interface IERC721 {
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) external;
}

contract Secretish is Ownable, IERC721Receiver {
    event ERC721GiftRecieved(
        address indexed gifter,
        address indexed ERC721Contracct,
        uint256 indexed tokenId
    );
    event EtherGiftGiven(address indexed gifter, uint256 indexed value);

    enum TokenType {
        ETH,
        ERC721,
        ERC1155
    }

    struct Gift {
        TokenType tokenType;
        uint256 tokenId;
        uint256 value;
        address tokenAddress;
    }

    //Change before pushing

    address[] public givers;

    //Change before pushing

    mapping(address giftGiver => Gift gifts) public addressesToGifts;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function giveEther() public payable {
        if (addressesToGifts[msg.sender].value != 0) {
            revert ALREADY_GAVE_A_GIFT();
        }
        if (msg.value < 0.1 ether) {
            revert NOT_ENOUGH_ETHER_SENT();
        }

        emit EtherGiftGiven(msg.sender, msg.value);

        givers.push(msg.sender);
        addressesToGifts[msg.sender] = Gift(
            TokenType.ETH,
            0,
            msg.value,
            address(0)
        );
    }

    function giveERC721(address _contractAddress, uint256 tokenId) public {
        if (addressesToGifts[msg.sender].value != 0) {
            revert ALREADY_GAVE_A_GIFT();
        }

        bytes memory data = abi.encode(_contractAddress);

        IERC721(_contractAddress).safeTransferFrom(
            msg.sender,
            address(this),
            tokenId,
            data
        );
    }

    function onERC721Received(
        address /*operator*/,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) public override returns (bytes4) {
        if (addressesToGifts[from].value != 0) {
            revert ALREADY_GAVE_A_GIFT();
        }
        address contractAddress = abi.decode(data, (address));

        emit ERC721GiftRecieved(from, contractAddress, tokenId);
        givers.push(from);
        addressesToGifts[from] = Gift(
            TokenType.ERC721,
            tokenId,
            1,
            contractAddress
        );

        return IERC721Receiver.onERC721Received.selector;
    }

    function getGift(
        address giftGiver
    ) public view returns (TokenType, uint256, uint256, address) {
        Gift memory gift = addressesToGifts[giftGiver];
        return (gift.tokenType, gift.tokenId, gift.value, gift.tokenAddress);
    }

    receive() external payable {}
}
