# build
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src
COPY . .
RUN dotnet publish -c Release -o /out

# runtime
FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app

# Create a non-root user
RUN adduser --disabled-password --gecos "" --home /app appuser \
    && chown -R appuser:appuser /app

# Copy the published app
COPY --from=build --chown=appuser:appuser /out ./

# Configure the app
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

# Switch to non-root user
USER appuser

ENTRYPOINT ["dotnet","Hyrox.Api.dll"]
