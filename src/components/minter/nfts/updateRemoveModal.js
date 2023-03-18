import React, { useState } from "react";
import PropTypes from "prop-types";
import {
  Button,
  Modal,
  Form,
  FloatingLabel,
  FormControl,
} from "react-bootstrap";

// modal that show info to update and remove nft from the marketplace
const URModal = ({ update, remove, show, onHide }) => {
  const [newPrice, setNewPrice] = useState(0);

  return (
    <Modal show={show} onHide={onHide} centered>
      <Modal.Header closeButton>
        <Modal.Title>NFT Information</Modal.Title>
      </Modal.Header>

      <Modal.Body>
        <Form>
          <FloatingLabel label="New Price" className="mb-2">
            <FormControl
              type="number"
              placeholder="Enter new price"
              onChange={(e) => {
                setNewPrice(e.target.value);
              }}
            />
          </FloatingLabel>
          <Button
            onClick={() => {
              update({ newPrice });
              onHide();
            }}
            variant="outline-primary"
            className="mx-2"
          >
            Update NFT
          </Button>
          <Button
            onClick={() => {
              remove();
              onHide();
            }}
            variant="outline-danger"
            className="mx-2"
          >
            Remove NFT
          </Button>
        </Form>
      </Modal.Body>

      <Modal.Footer>
        <Button variant="outline-secondary" onClick={onHide}>
          Close
        </Button>
      </Modal.Footer>
    </Modal>
  );
};

URModal.propTypes = {
  // props passed into this component
  //   show: PropTypes.instanceOf(Object).isRequired,
  onHide: PropTypes.func.isRequired,
  update: PropTypes.func.isRequired,
  remove: PropTypes.func.isRequired,
};

export default URModal;
