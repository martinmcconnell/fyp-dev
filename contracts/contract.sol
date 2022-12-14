pragma solidity >=0.7.0 <0.9.0;

import "./IPFS.sol" as IPFS;

contract ScientificJournal {

    // Define an instance of the IPFS contract
    IPFS.IpfsContract ipfs = new IPFS.IpfsContract();
    
    // Define a struct for papers submitted to the journal
    struct Paper {
        string title;
        string author;
        string[] keywords;
        bytes file;
        address owner;
    }

    // Define a mapping to store papers submitted to the journal
    mapping(string => Paper) public papers;

    // Define a struct for reviewers of the journal
    struct Reviewer {
        string name;
        bool isActive;
    }

    // Define a mapping to store reviewers of the journal
    mapping(address => Reviewer) public reviewers;

    // Define a struct for reviews of papers in the journal
    struct Review {
        uint rating;
        string feedback;
    }

    // Define an array to store reviews of papers in the journal
    Review[] public reviews;

    // Define a storage struct for a journal entry on the Ethereum blockchain
    struct JournalEntry {
        string ipfsHash;
        address owner;
    }

    // Define a mapping from entryId to journal entry
    mapping (uint256 => JournalEntry) public journalEntries;
    
    // Define an event for submitting a paper to the journal
    event PaperSubmitted(string indexed title, address indexed owner);

    // Define an event for publishing a paper in the journal
    event PaperPublished(string indexed title, address indexed owner);

    function encodeJournalEntry(string memory title) private pure returns (bytes memory) {
    // Encode the journal entry's title as a byte array
    return abi.encode(title);
    }

    function addToIPFS(bytes memory journalBytes) private view returns (bytes memory) {
        // Add the journalBytes to IPFS and return the IPFS hash for the entry
         bytes memory journalBytes = encodeJournalEntry(title);
        return ipfs.add(journalBytes);
    }

    // Define a function for submitting a paper to the journal
    function submitPaper(string memory title, string memory author, string[] memory keywords, bytes memory file) public payable {
        // Check if the submission fee has been paid
        require(msg.value >= 0.01 ether, "Submission fee must be paid");
        
        // Check if the paper has not already been submitted
        require(papers[title].owner == address(0), "Paper has already been submitted");

        // Store the paper in the mapping
        papers[title] = Paper({
            title: title,
            author: author,
            keywords: keywords,
            file: file,
            owner: msg.sender
        });

        // Emit an event to signal the submission of the paper
        emit PaperSubmitted(title, msg.sender);
    }
    
    function publishJournal(string memory title, address owner) public {
        // Emit an event to indicate that a paper has been published in the journal
        emit PaperPublished(title, owner);

        // Store the journal entry on IPFS
        // First, encode the journal entry as a byte array
        bytes memory journalBytes = encodeJournalEntry(title);

        // Then, add the journal entry to IPFS and get the IPFS hash for the entry
        bytes memory ipfsHash = addToIPFS(journalBytes);

        // Use the IPFS hash as the unique identifier for the journal entry on the Ethereum blockchain
        bytes32 entryId = keccak256(abi.encodePacked(ipfs));

        // Store the journal entry on the Ethereum blockchain using the entryId as the key
        JournalEntry storage journalEntry = journalEntries[entryId];
        journalEntry.ipfsHash = ipfsHash;
        journalEntry.owner = owner;
    }
}

