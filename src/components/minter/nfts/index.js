import { useContractKit } from "@celo-tools/use-contractkit";
import React, { useEffect, useState } from "react";
import { toast } from "react-toastify";
import PropTypes from "prop-types";
import AddNfts from "./Add";
import SellNft from "./Sell";
import Nft from "./Card";
import Loader from "../../ui/Loader";
import { NotificationSuccess, NotificationError } from "../../ui/Notifications";
import {
  getActiveItem,
  getNfts,
  createNft,
  listNft,
} from "../../../utils/minter";
import { Row } from "react-bootstrap";
import { x } from "../../../context";

const NftList = ({ minterContract, name }) => {
  /* performActions : used to run smart contract interactions in order
   *  address : fetch the address of the connected wallet
   */
  const { performActions, address } = useContractKit();
  const [loading, setLoading] = useState(false);
  const { content, nfts, setNfts, activeNfts, setActiveNfts } =
    React.useContext(x);

  const handleResetAsset = () => getAssets();

  const getAssets = async () => {
    try {
      setLoading(true);

      // fetch all nfts from the smart contract
      if (content === "collection") {
        const _nfts = await getNfts(minterContract);
        setNfts(_nfts);
      } else if (content === "marketplace") {
        const _activeNfts = await getActiveItem(minterContract);
        setActiveNfts(_activeNfts);
      }
      if (!nfts || !activeNfts) return;
    } catch (error) {
      console.log({ error });
    } finally {
      setLoading(false);
    }
  };

  const sellNft = async (data) => {
    try {
      if (nfts[data.tokenId] === undefined) {
        toast(<NotificationError text="NFT does not exist." />);
      } else if (nfts[data.tokenId].owner !== address) {
        toast(<NotificationError text="You are not the owner of the NFT." />);
      } else if (nfts[data.tokenId].price !== undefined) {
        toast(<NotificationError text="NFT already in marketplace." />);
      } else {
        setLoading(true);

        // create an nft functionality
        await listNft(minterContract, performActions, data);
        getAssets();
      }
    } catch (error) {
      console.log({ error });
      toast(<NotificationError text="Failed to create an NFT." />);
    } finally {
      setLoading(false);
    }
  };

  const addNft = async (data) => {
    try {
      setLoading(true);

      // create an nft functionality
      await createNft(minterContract, performActions, data);
      toast(<NotificationSuccess text="Updating NFT list...." />);
      getAssets();
    } catch (error) {
      console.log({ error });
      toast(<NotificationError text="Failed to create an NFT." />);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    try {
      if (address && minterContract) {
        getAssets();
      }
    } catch (error) {
      console.log({ error });
    }
  }, [minterContract, address, content]);
  if (address) {
    return (
      <>
        {!loading ? (
          <>
            <div className="d-flex justify-content-between align-items-center mb-4">
              <h1 className="fs-4 fw-bold mb-0">{name}</h1>

              {/* give the add NFT permission to user who deployed the NFT smart contract */}
              {content === "collection" ? (
                <AddNfts save={addNft} address={address} />
              ) : (
                <SellNft save={sellNft} />
              )}
            </div>
            <Row xs={1} sm={2} lg={3} className="g-3  mb-5 g-xl-4 g-xxl-5">
              {/* display all NFTs */}
              {content === "collection"
                ? nfts.map((_nft) => (
                    <Nft
                      key={_nft.index}
                      nft={{
                        ..._nft,
                      }}
                      contract={minterContract}
                      rerestAsset={handleResetAsset}
                    />
                  ))
                : activeNfts.map((_nft) => {
                    if (
                      _nft.seller !=
                      "0x0000000000000000000000000000000000000000"
                    ) {
                      return (
                        <Nft
                          key={_nft.index}
                          nft={{
                            ..._nft,
                          }}
                          contract={minterContract}
                          rerestAsset={handleResetAsset}
                        />
                      );
                    }
                  })}
            </Row>
          </>
        ) : (
          <Loader />
        )}
      </>
    );
  }
  return null;
};

NftList.propTypes = {
  // props passed into this component
  minterContract: PropTypes.instanceOf(Object),
  updateBalance: PropTypes.func.isRequired,
};

NftList.defaultProps = {
  minterContract: null,
};

export default NftList;
