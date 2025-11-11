import { Stack, IStackTokens, Text, TextField, Link } from '@fluentui/react';

export const Quickstart = () => {

  const stackTokens: IStackTokens ={
    childrenGap: 20,
    padding: 20
  }

  const endpoint = typeof window !== 'undefined' ? window.location.origin : 'https://localhost';

  return (
    <Stack tokens={stackTokens}>
      <Text variant='large'>Congratulations! Your Azure Communication Services Emulator is running.</Text>
      <Text>Connect a sample app to it, or browse the <Link href={`${endpoint}/swagger/index.html`}>Swagger API definition.</Link></Text>
      <TextField label='Endpoint' readOnly defaultValue={endpoint}/>
      <TextField label='Connection String' readOnly defaultValue={`endpoint=${endpoint}/;accessKey=pw==`}/>
    </Stack>
  );
}