var testvar = 0;

function CallMe()
{
	testvar++;
	ShowMessage(testvar);
}

function main()
{
	ShowMessage(testvar);
	App.testCall();
	ShowMessage('Test message');
}

