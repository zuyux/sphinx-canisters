export const idlFactory = ({ IDL }) => {
  return IDL.Service({
    'getOpenAIKey' : IDL.Func([], [IDL.Text], ['query']),
    'getOwnerPrivateKey' : IDL.Func([], [IDL.Text], ['query']),
  });
};
export const init = ({ IDL }) => { return []; };
