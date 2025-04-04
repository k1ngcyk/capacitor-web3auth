import { CapWeb3Auth } from 'capacitor-web3auth';

window.testEcho = () => {
    const inputValue = document.getElementById("echoInput").value;
    CapWeb3Auth.echo({ value: inputValue })
}
