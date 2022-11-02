function P1975()
    years = 1950:10:1990;
    service = 10:10:30;
    wage = [150.697 169.592 187.652
            179.323 195.072 250.287
            203.212 239.092 322.767
            226.505 273.706 426.730
            249.633 370.281 598.243];
    mesh(service,years,wage) %绘原始数据图
    w=interp2(service,years,wage,15,1975); %求点(15,1975)处的值
    disp(w);
end

