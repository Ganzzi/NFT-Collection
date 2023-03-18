import { createContext, useState } from "react";

let content = "collection";

export const getContent = () => {
  return content;
};

export const setContent = (str) => {
  content = str;
};

export const x = createContext();

export const Provider = ({ children }) => {
  const [content, setContent] = useState("collection");
  const [nfts, setNfts] = useState([]);
  const [activeNfts, setActiveNfts] = useState([]);

  return (
    <x.Provider
      value={{ content, setContent, nfts, setNfts, activeNfts, setActiveNfts }}
    >
      {children}
    </x.Provider>
  );
};
