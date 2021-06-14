pragma solidity 0.6.7;

import "./mocks/SurplusAuctionHouseMock.sol";


contract GeneralBurningFuzz is BurningSurplusAuctionHouseMock {

    constructor () public {
        SAFEEngine safeEngine_ = new SAFEEngine();
        TokenMock tokenMock = new TokenMock("Mock", "Mock");
        setUp(address(safeEngine_), address(tokenMock));

        // Give coins to sender accounts
        SAFEEngine(address(safeEngine)).createUnbackedDebt(address(0x8), address(0x00a329C0648769a73afAC7F9381e08fb43DBEA70), 1000000000000 ether * 10**27);
        SAFEEngine(address(safeEngine)).createUnbackedDebt(address(0x8), address(0x10000), 1000000000000 ether * 10**27);
        SAFEEngine(address(safeEngine)).createUnbackedDebt(address(0x8), address(0x20000), 1000000000000 ether * 10**27);

        tokenMock.mint(address(0x00a329C0648769a73afAC7F9381e08fb43DBEA70), 100000000000 ether);
        tokenMock.mint(address(0x10000), 100000000000 ether);
        tokenMock.mint(address(0x20000), 100000000000 ether);

        // Authorizing Echidna Accounts
        authorizedAccounts[address(0x10000)] = 1;
        authorizedAccounts[address(0x20000)] = 1;
        authorizedAccounts[address(0x00a329C0648769a73afAC7F9381e08fb43DBEA70)] = 1;

    }
}
contract GeneralRecyclingFuzz is RecyclingSurplusAuctionHouseMock {

    constructor () public {
        SAFEEngine safeEngine_ = new SAFEEngine();
        TokenMock tokenMock = new TokenMock("Mock", "Mock");
        setUp(address(safeEngine_), address(tokenMock));
        protocolTokenBidReceiver = address(0x8);

        // Give coins to sender accounts
        SAFEEngine(address(safeEngine)).createUnbackedDebt(address(0x8), address(0x00a329C0648769a73afAC7F9381e08fb43DBEA70), 1000000000000 ether * 10**27);
        SAFEEngine(address(safeEngine)).createUnbackedDebt(address(0x8), address(0x10000), 1000000000000 ether * 10**27);
        SAFEEngine(address(safeEngine)).createUnbackedDebt(address(0x8), address(0x20000), 1000000000000 ether * 10**27);

        tokenMock.mint(address(0x00a329C0648769a73afAC7F9381e08fb43DBEA70), 100000000000 ether);
        tokenMock.mint(address(0x10000), 100000000000 ether);
        tokenMock.mint(address(0x20000), 100000000000 ether);

        // Authorizing Echidna Accounts
        authorizedAccounts[address(0x10000)] = 1;
        authorizedAccounts[address(0x20000)] = 1;
        authorizedAccounts[address(0x00a329C0648769a73afAC7F9381e08fb43DBEA70)] = 1;

    }
}

contract GeneralPostSettlementFuzz is PostSettlementSurplusAuctionHouseMock {

    constructor () public {
        SAFEEngine safeEngine_ = new SAFEEngine();
        TokenMock tokenMock = new TokenMock("Mock", "Mock");
        setUp(address(safeEngine_), address(tokenMock));

        // Give coins to sender accounts
        SAFEEngine(address(safeEngine)).createUnbackedDebt(address(0x8), address(0x00a329C0648769a73afAC7F9381e08fb43DBEA70), 1000000000000 ether * 10**27);
        SAFEEngine(address(safeEngine)).createUnbackedDebt(address(0x8), address(0x10000), 1000000000000 ether * 10**27);
        SAFEEngine(address(safeEngine)).createUnbackedDebt(address(0x8), address(0x20000), 1000000000000 ether * 10**27);

        tokenMock.mint(address(0x00a329C0648769a73afAC7F9381e08fb43DBEA70), 100000000000 ether);
        tokenMock.mint(address(0x10000), 100000000000 ether);
        tokenMock.mint(address(0x20000), 100000000000 ether);

        // Authorizing Echidna Accounts
        authorizedAccounts[address(0x10000)] = 1;
        authorizedAccounts[address(0x20000)] = 1;
        authorizedAccounts[address(0x00a329C0648769a73afAC7F9381e08fb43DBEA70)] = 1;
    }
}

contract StatefulFuzzBase {

    // --- Fuzzing Contracts ---
    SurplusAuctionHouseLike auctionHouse;
    SAFEEngine safeEngine;
    TokenMock tokenMock;

    // --- Auction Players ---
    Bidder[] bidders;

    // --- Tracking Variables ---
    // tracker to check if contract has been initialized
    bool inited;
    //track already settled auctions
    mapping(uint256 => bool) settledAuctions;
    mapping(address => uint) settledBalance;
    mapping(uint => bool) startedAuctions;
    uint[] restartedAuctions;


    modifier setUp() virtual {
      if(!inited) baseSetup();
      _;
    }

    function baseSetup() internal virtual {
      safeEngine = new SAFEEngine();
      tokenMock = new TokenMock("Mock", "Mock");
      inited = true;
   }

    //--- Math ---
    function addition(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, "Coin/add-overflow");
    }
   
   //--- Base Echidna Tests ---
    function echidna_sanity() public setUp returns(bool) {
        return true;
    }

    function echidna_contract_is_enabled() public setUp returns(bool) {
        return auctionHouse.contractEnabled() == 1;
    }

    function echidna_protocolToken() public setUp returns(bool) {
        return address(auctionHouse.protocolToken()) != address(0);
    }

    function echidna_safe_engine() public setUp returns(bool) {
        return address(auctionHouse.safeEngine()) != address(0);
    }

    function echidna_bidIncrease() public setUp returns(bool) {
        return auctionHouse.bidIncrease() == 1.05E18;
    }

    function echidna_bidDuration() public setUp returns(bool) {
        return auctionHouse.bidDuration() == 3 hours;
    }

    function echidna_totalAuctionLength() public setUp returns(bool) {
        return auctionHouse.totalAuctionLength() == 2 days;
    }

    function echidna_started_auctions_arent_null() public setUp returns(bool) {
        uint totalAuctions = auctionHouse.auctionsStarted();
        bool valid = true;
        for (uint256 i = 0; i < totalAuctions; i++) {
            (uint256 bidAmount, uint256 amountToSell,address highBidder,uint48 bidExpiry,uint48  auctionDeadline) = auctionHouse.bids(i);
            if (settledAuctions[i]) continue; //auction already closed
            valid = bidAmount != 0 && amountToSell != 0 && highBidder != address(0) && bidExpiry != 0 && auctionDeadline != 0;
            if(!valid) return false;
        }
        return true;
    }

    function echidna_restardedOnlyStarted() public setUp returns(bool) {
        bool valid = true;
        for (uint256 i = 0; i < restartedAuctions.length; i++) {
            valid = startedAuctions[restartedAuctions[i]];
            if(!valid) return false;
        }
        return true;
    }

    //--- Base Auction Actions ---
    function startAuction(uint amountToSell, uint initialBid) external setUp {
       uint id = auctionHouse.startAuction(amountToSell, initialBid);
       startedAuctions[id] = true;
    }

    function restartAuction(uint256 id) external setUp {
        // To make the most of echidna, we'll covert the id to one of the open auctions
        id = id > auctionHouse.auctionsStarted() ? id % auctionHouse.auctionsStarted() : id;
        auctionHouse.restartAuction(id);
        restartedAuctions.push(id);
    }

    function increaseBidSize(uint256 id, uint256 amountToBuy, uint256 bid) external setUp {
        // To make the most of echidna, we'll covert the id to one of the open auctions
        id = id > auctionHouse.auctionsStarted() ? id % auctionHouse.auctionsStarted() : id;
        auctionHouse.increaseBidSize(id, amountToBuy, bid);
    }

    function settleAuction(uint256 id) external setUp {
        // To make the most of echidna, we'll covert the id to one of the open auctions
        id = id > auctionHouse.auctionsStarted() ? id % auctionHouse.auctionsStarted() : id;
        settledAuctions[id] = true;
        (, uint256 amountToSell,address highBidder,,) = auctionHouse.bids(id);
        settledBalance[highBidder] = addition(settledBalance[highBidder], amountToSell);
        auctionHouse.settleAuction(id);
    }

    function terminateAuctionPrematurely(uint256 id) external setUp {
        // To make the most of echidna, we'll covert the id to one of the open auctions
        id = id > auctionHouse.auctionsStarted() ? id % auctionHouse.auctionsStarted() : id;
        auctionHouse.terminateAuctionPrematurely(id);
    }

    function increaseBidSizeWithBidder(uint8 bidder, uint256 id, uint256 amountToBuy, uint256 bid) external setUp {
        // To make the most of echidna, we'll covert the id to one of the open auctions
        id = id > auctionHouse.auctionsStarted() ? id % auctionHouse.auctionsStarted() : id;
        bidders[bidder % bidders.length].increaseBidSize(id, amountToBuy, bid);
    }

    //--- Fuzzing Actions ---
    function createBidders(uint8 amount) public {
        for (uint256 index = 0; index < amount; index++) {
            
            Bidder newBidder = new Bidder(auctionHouse);
            bidders.push(newBidder);
            safeEngine.createUnbackedDebt(address(0x8), address(newBidder), 10000 ether * 10**27);
        }
    }
}

contract GovernanceFuzz is StatefulFuzzBase {
    function modifyBidDecrease(uint256 val) external {
        auctionHouse.modifyParameters("bidDecrease", val);
    }

    function modifyBidDuration(uint256 val) external {
        auctionHouse.modifyParameters("bidDuration", val);
    }

    function modifyTotalAuctionLength(uint256 val) external {
        auctionHouse.modifyParameters("totalAuctionLength", val);
    }
}

contract BurningFuzz is StatefulFuzzBase {

     function baseSetup() internal override {
        super.baseSetup();
        auctionHouse = SurplusAuctionHouseLike(address(new BurningSurplusAuctionHouseMock()));
        auctionHouse.setUp(address(safeEngine), address(tokenMock));

        safeEngine.addAuthorization(address(auctionHouse));
   }

}

contract RecyclingFuzz is StatefulFuzzBase {

     function baseSetup() internal override {
        super.baseSetup();
        auctionHouse = SurplusAuctionHouseLike(address(new RecyclingSurplusAuctionHouseMock()));
        auctionHouse.setUp(address(safeEngine), address(tokenMock));

        safeEngine.addAuthorization(address(auctionHouse));
   }

}

contract PostSettlementFuzz is StatefulFuzzBase {

     function baseSetup() internal override {
        super.baseSetup();
        auctionHouse = SurplusAuctionHouseLike(address(new PostSettlementSurplusAuctionHouseMock()));
        auctionHouse.setUp(address(safeEngine), address(tokenMock));

        safeEngine.addAuthorization(address(auctionHouse));
   }
}

contract BurningGovernanceFuzz is GovernanceFuzz {

     function baseSetup() internal override {
        super.baseSetup();
        auctionHouse = SurplusAuctionHouseLike(address(new BurningSurplusAuctionHouseMock()));
        auctionHouse.setUp(address(safeEngine), address(tokenMock));

        safeEngine.addAuthorization(address(auctionHouse));
   }

}

contract RecyclingGovernanceFuzz is GovernanceFuzz {

     function baseSetup() internal override {
        super.baseSetup();
        auctionHouse = SurplusAuctionHouseLike(address(new RecyclingSurplusAuctionHouseMock()));
        auctionHouse.setUp(address(safeEngine), address(tokenMock));

        safeEngine.addAuthorization(address(auctionHouse));
   }

}

contract PostSettlementGovernanceFuzz is GovernanceFuzz {

     function baseSetup() internal override {
        super.baseSetup();
        auctionHouse = SurplusAuctionHouseLike(address(new PostSettlementSurplusAuctionHouseMock()));
        auctionHouse.setUp(address(safeEngine), address(tokenMock));

        safeEngine.addAuthorization(address(auctionHouse));
   }
}