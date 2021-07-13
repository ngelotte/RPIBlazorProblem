#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0-bullseye-slim AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0-bullseye-slim AS build
WORKDIR /src
COPY ["RaspberryPITest/RaspberryPITest.csproj", "RaspberryPITest/"]
RUN dotnet restore "RaspberryPITest/RaspberryPITest.csproj"
COPY . .
WORKDIR "/src/RaspberryPITest"
RUN dotnet build "RaspberryPITest.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "RaspberryPITest.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENV DOTNET_RUNNING_IN_CONTAINER=true \
  ASPNETCORE_URLS=http://+:8080
EXPOSE 8080
ENTRYPOINT ["dotnet", "RaspberryPITest.dll"]