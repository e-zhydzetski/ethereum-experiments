pragma solidity ^0.6.7;

import "https://github.com/smartcontractkit/chainlink/blob/master/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract ethprice {

    AggregatorV3Interface internal priceFeed;

    constructor() public {
        priceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
    }

    function getLatestPrice() public view returns (int) {
        (
            uint80 _roundID, 
            int price,
            uint _startedAt,
            uint _timeStamp,
            uint80 _answeredInRound
        ) = priceFeed.latestRoundData();
        return price;
    }
}